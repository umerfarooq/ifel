class SectionTemplatesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :require_admin , :except => [:overview, :display, :download]
  before_filter { |c| c.active_tab=:checklist }

  def index
    if params[:type]
      if params[:type] == 'wibo'
        @section_templates = SectionTemplate.wibo.sequence_wise      
      else     
        @section_templates = SectionTemplate.ifel.sequence_wise        
      end
    else
      @section_templates = SectionTemplate.wibo.sequence_wise
    end    
  end

  def show
    @section_template = SectionTemplate.find params[:id]
    redirect_to section_template_item_templates_path(@section_template)
  end

  def new
    @section_template = SectionTemplate.new
  end

  def create
    @section_template = SectionTemplate.new(params[:section_template])
    @section_template.state = State.find_by_name('inactivate')
    if @section_template.save
      flash[:notice] = "Section Template successfully added."
      redirect_to section_templates_path(:type => @section_template.associated_with)
    else
      render :action => 'new'
    end
  end

  def edit
    @section_template = SectionTemplate.find params[:id]
  end

  def update
    @section_template = SectionTemplate.find params[:id]
    if @section_template.update_attributes(params[:section_template])
      flash[:notice] = "Section Template successfully updated."
      redirect_to section_template_item_templates_path(@section_template, :type => @section_template.associated_with)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @section_template = SectionTemplate.find params[:id]
    if @section_template.destroy
      flash[:success] = "Section Template is deleted."
    else
      flash[:notice] = "Section Template can't be deleted."
    end
    return redirect_to :back
  end

  def display
    section = @section_template.find_by_id params[:id]
    if section.blank?
      flash[:error] = "The section you requested could not be found in your project."
      return redirect_to @section_template.resources
    else
      return redirect_to(:controller => 'resources', :action => 'resource_library', :id => @section_template.id, :display_section => section.id)
    end
  end


  def publish
    section_template = SectionTemplate.find params[:id]
    if section_template.state.is_activated?
      section_template.update_attribute(:state, State.find_by_name('publish'))
      flash[:notice] = "Section Template successfully published"
    else
      flash[:notice] = "Section Template is not publishable"
    end
    return redirect_to :back
  end

  def activate
    section_template = SectionTemplate.find params[:id]
    if section_template.state.is_inactivated?
      section_template.update_attribute(:state, State.find_by_name('activate'))
      flash[:notice] = "Section Template successfully activated"
    else
      flash[:notice] = "Section Template is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    section_template = SectionTemplate.find params[:id]
    if section_template.state.is_inactivated?
      flash[:notice] = "Section Template is not inactivatable"
    else
      section_template.update_attribute(:state, State.find_by_name('inactivate'))
      flash[:notice] = "Section Template successfully inactivated"
    end
    return redirect_to :back
  end

  def move_up
    section_template = SectionTemplate.find params[:id]
    if section_template.move_up
      flash[:notice] = "Section Template successfully moved up"
    else
      flash[:notice] = "Section Template could not be moved up"
    end
    return redirect_to :back
  end

  def move_down
    section_template = SectionTemplate.find params[:id]
    if section_template.move_down
      flash[:notice] = "Section Template successfully moved down"
    else
      flash[:notice] = "Section Template could not be moved down"
    end
    return redirect_to :back
  end
  
  def download
    section_template = SectionTemplate.find params[:id]  
    send_file section_template.chart.path
  end

  def overview
    #    enable_light_box
    #    @section_templates = SectionTemplate.all
    @section_templates = SectionTemplate.find_all_by_state_id(State.find_by_name('publish').id)
    render :layout => false
  end
  
  def synchronize
    section_template = SectionTemplate.find params[:id]
#    if section_template.state.is_published?  
      if section_template.synchronized
        flash[:notice] = "Section Template successfully synchronized with existing Projects"
      else
        flash[:notice] = "Section Template can't be synchronized with existing Projects"
      end      
      #    else
    #      flash[:notice] = "Section Template should be Published before synchronized with existing Projects"
    #    end
    return redirect_to :back
  end

end
