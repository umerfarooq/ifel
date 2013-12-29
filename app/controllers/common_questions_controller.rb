class CommonQuestionsController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :redirect_nyu_user
  before_filter { |c| c.active_tab=:common_questions }
  before_filter :set_new_design_theme, :except => [:list,:new,:create,:edit,:update]
  before_filter :get_sections
  before_filter :get_selected_question,:get_selected_panel_id, :only => [:index, :detail, :show]
  before_filter :require_admin, :only => [:list,:new,:create,:edit,:update]
  before_filter :is_add_as_statement,:is_adding_as_root, :only => [:new,:edit]
  before_filter :get_main_title_and_subtitle, :only => [:list,:index,:detail]

  def index
  end
 
  def new
    @question = CommonQuestion.new
  end

  def create
    @question = CommonQuestion.new(params[:common_question])
    if @question.save(params[:common_question])
      flash[:success] = "Common Question successfully added."      
      _redirection(@question)
    else
      unless params[:common_question][:parent_id].blank?
        parent = CommonQuestion.find(params[:common_question][:parent_id])
      end
      if params[:common_question][:section_template_id]
        @add_as_statement = true
      end
      @add_as_root = true
      unless parent.blank?
        if parent.at_first_level?
          flash[:validation_errors] = @question.errors.full_messages
          return redirect_to new_common_question_path(:parent_id => parent.id)
        end
      end
      render :action => :new
    end
  end

  def refresh_all_sliders
    @sections = SectionTemplate.published.sequence_wise
    @selected_question = CommonQuestion.get_parents.published.sequence_wise.first.children.sequence_wise.first rescue nil
    @selected_section = @selected_question.parent.section_template unless @selected_question.blank?
    @panel_id = params[:id]
    @closeAllSliders = 'false'
    render :partial => 'slider_panel'
  end

  def detail
    sub_questions = @selected_question.parent.children.published.sequence_wise
    return render :partial => 'questions_panel', :locals => { :index => @panel_id, :sub_questions => sub_questions, :section => @selected_section, :statement_object => @selected_section.common_question }
  end

  def edit
    @question = CommonQuestion.find params[:id]
  end

  def update
    @question = CommonQuestion.find params[:id]
    if @question.update_attributes(params[:common_question])
      flash[:notice] = "Common Question updated successfully."
      _redirection(@question)
    else
      if params[:common_question][:section_template_id]
        @add_as_statement = true
      end
      @add_as_root = true
      if @question.at_root_level?
        flash[:validation_errors] = @question.errors.full_messages
        return redirect_to edit_common_question_path(@question, :is_statement => 'true', :section_template_id => @question.section_template_id.to_s )
      end
      if @question.at_second_level?
        flash[:validation_errors] = @question.errors.full_messages
        return redirect_to edit_common_question_path(@question, :parent_id => @question.parent.id )
      end
      render :action => 'edit', :parent_id => @question.parent_id
    end
  end

  def display
  end

  def list
    @statements = CommonQuestion.roots.sort_by { |obj| obj.sequence_number }
  end

  def publish
    question = CommonQuestion.find params[:id]
    if question.publish
      flash[:notice] = "Common Question successfully published"
    else
      flash[:notice] = "Common Question is not publishable"
    end
    return redirect_to :back
  end

  def activate
    question = CommonQuestion.find params[:id]
    if question.activate
      flash[:notice] = "Common Question successfully activated"
    else
      flash[:notice] = "Common Question is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    question = CommonQuestion.find params[:id]
    if question.inactivate
      flash[:notice] = "Common Question successfully inactivated"
    else
      flash[:notice] = "Common Question is not inactivatable"
    end
    return redirect_to :back
  end

  def move_up
    question = CommonQuestion.find params[:id]
    if question.move_up
      flash[:notice] = "Question successfully moved up"
    else
      flash[:notice] = "Question could not be moved up"
    end
    return redirect_to :back
  end

  def move_down
    question = CommonQuestion.find params[:id]
    if question.move_down
      flash[:notice] = "Question successfully moved down"
    else
      flash[:notice] = "Question could not be moved down"
    end
    return redirect_to :back
  end

  def flvplayer
    video_path = params[:video_path]
    render :partial => 'shared/flvplayer', :locals => { :video_path => video_path, :width => '640', :height => '396', :padding => nil }
  end

  def have_a_question
    common_question = CommonQuestion.new
    @question = Hash.new
    @question[:name] = params[:name]
    @question[:email] = params[:email]
    @question[:question] = params[:question]
    unless @question.blank?
      common_question.deliver_have_a_question_email(@question)
      return render :text => {:success => true}.to_json
    end
    return render :text => {:success => false}.to_json
  end

  private
  def _redirection question
    if question.at_root_level?
      redirect_to list_common_questions_path
    else
      if question.at_first_level?
        redirect_to edit_common_question_path(question.parent, :is_statement => true, :section_template_id => question.parent.section_template.id )
      else
        redirect_to edit_common_question_path(question.parent, :parent_id => question.parent.parent.id )
      end
    end
  end
  def get_main_title_and_subtitle
    @main_title = MarketingTextMessage.find_by_page_and_location('common_question','main_title')
  end
  def get_sections
    @sections = SectionTemplate.published.sequence_wise
    @closeAllSliders = 'true'
  end
  def get_selected_question
    @selected_question = CommonQuestion.find_by_id params[:id] || (CommonQuestion.get_parents.published.sequence_wise.first.children.sequence_wise.first rescue nil)
  end
  def get_selected_panel_id
    @selected_section = @selected_question.parent.section_template unless @selected_question.blank?
    @panel_id = @sections.index(@selected_section) unless @selected_section.blank?
  end  
  def is_add_as_statement
    if !params[:is_statement].blank?
      @add_as_statement = true
      @add_as_root = true
    end
  end
  def is_adding_as_root
    unless params[:parent_id].blank?
      if CommonQuestion.find_by_id(params[:parent_id]).parent.nil?
        @add_as_root = true
      end
    end    
  end
end
