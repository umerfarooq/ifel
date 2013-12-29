class ProjectsController < ApplicationController
  before_filter :require_user
  before_filter :require_payment
  before_filter { |c| c.active_tab=:startup_workspace }
  before_filter :set_new_design_theme
  before_filter :load_project, :only=>[:show, :print_roadmap_steps]
  before_filter :load_sections, :load_section_to_open, :load_recent_items,:load_closely_due_section,:load_upcoming_todos,:load_content,:set_session_variables, :only=>:show

  # Deprecated Functions - Only Workable with the Old Designs
  def index
    #if current_user.project.blank?
    #  return redirect_to new_project_url
    #else
    return redirect_to current_user.project
    #end
  end

  def new
    return redirect_to current_user.project unless current_user.project.blank?
    @project = Project.new
    @project.start_date = Date.today
    @tour_video = MarketingMultimediaMessage.find_by_page_and_location("how_it_works", "take_a_tour")
    front_modules
  end

  def create
    logger.debug "__ __CONTROLLER:projects__ __"
    logger.debug "__ __ACTION:create__ __"
    logger.debug "__ __START:#{Time.now}__ __"
    logger.debug "__ __params:#{params.inspect}__ __"

    #    if current_user.project.blank?
    @project = Project.new(params[:project])
    #    return render :json => @project
    @project.user = current_user
    if @project.save
      logger.debug "__ __PROJECT_SAVED:#{Time.now}__ __"
      redirect_to @project
      #        redirect_to :action => 'show'
    else
      @tour_video = MarketingMultimediaMessage.find_by_page_and_location("how_it_works", "take_a_tour")
      front_modules
      render :action => 'new'
    end
    #    else
    #      redirect_to :action => 'show'
    #    end
    logger.debug "__ __END:#{Time.now}__ __"
  end

  def update
    @project = @current_user.project
    @project.update_attribute(:user_answer, params[:project][:user_answer])
    redirect_to :back
  end

  def show_old
    return redirect_to new_project_url if current_user.project.blank?
    @project = current_user.project
    @tour_video = MarketingMultimediaMessage.find_by_page_and_location("how_it_works", "take_a_tour")
    front_modules
    if(params[:display_section].blank? == false)
      @open_section = @project.sections.find_by_id(params[:display_section])
      if @open_section.blank?
        flash.now[:error] = "The section you requested could not be found in your project."
      else
        @display_type = "Section"
      end
    elsif(params[:display_item].blank? == false)
      @open_item = @project.items.find_by_id(params[:display_item])
      if @open_item.blank?
        flash.now[:error] = "The item you requested could not be found in your project."
      else
        @open_section = @open_item.section
        @display_type = "Item"
      end
    end
    @open_section ||= @project.sections.find_by_id(@project.open_section) || @project.sections.first
    @display_type ||= "none"
  end

  def summary
    project = Project.find_by_id(params[:id])
    if project && project == @current_user.project
      #      return render :json => {:success => true, :project => @current_user.project.as_json(:include => {:sections => {:only => [:id, :item_count, :items_completed_count] } }, :only => [:business_name, :percent])}
      return render :json => {
        :success => true,
        :project => @current_user.project.as_json(
          :include => {
            :sections => {
              :include => {
                :items => {:only => [:id], :methods => [:ended?, :edited?]}
              },
              :only => [:id, :item_count, :items_completed_count],
              :methods => [:ended?, :ended_items_count]
            }
          },
          :only => [:business_name, :percent]
        )
      }
    else
      return render :json => {:success => true, :message => "Project not found in your projects"}
    end
  end

  def overview
    @project = @current_user.project
    render :layout => false
  end

  def print
    @project = @current_user.project
    render :layout => false
  end

  def set_opened_section
    #    return render :json => params
    @project = @current_user.project
    section = @current_user.project.sections.find_by_id params[:section_id]
    @current_user.project.update_attribute(:open_section, section.id) unless section.blank?
    if section.blank?
      return render :json => {:success => false, :message => "The section you requested could not be found."}
    else
      return render :json => {:success => true, :open_section => @current_user.project.open_section}
    end
    #    respond_to do |format|
    #      format.html {
    #        flash[:error] = "The section you requested could not be found in your project." if section.blank?
    #        return redirect_to home_url
    #      }
    #      format.js {
    #      }
    #    end
  end

  def search
    #    return render :text => params.inspect
    #    @search_results = ThinkingSphinx.search(params[:keyword],:conditions=>{:user_id=>[@current_user.id.to_s,'']},:page=>params[:page],:per_page=>20)
    @query = params[SEARCH_FIELD.to_sym]
    @search_results = ThinkingSphinx.search(
      @query,
      :conditions => { :user_id => [@current_user.id.to_s, ''] },
      :page => params[:page],
      :per_page => SEARCH_PAGINATION_COUNT, :retry_stale => true)
    SearchTerm.searched(@query, request.referer, 'internal')
  end

  def congratulation
    render  :layout=>false
  end

  def guidance
    #    enable_light_box
    render :layout => false
  end

  def update_answer
    project = @current_user.project
    if project.blank?
      return render :json => {:success => false}
    else
      project.update_attribute(:user_answer, params[:user_answer])
      return render :json => {:success => true, :user_answer => project.user_answer}
    end
  end

  # New Function - Workable with New Designs
  def show
    @is_item_detail= false
    if !params[:is_item_detail].blank?
      @is_item_detail= params[:is_item_detail]
      @item_for_detail = Item.find(params[:item].to_i)
      @item_contents = MarketingTextMessage.get_roadmap_contents
      @post_question_summary = MarketingTextMessage.find_by_page_and_location("messages", "post_question")
      @section_templates = SectionTemplate.published
    end

    #    unless params[:is_section_detail].blank?
    #      @is_section_detail = params[:is_section_detail]
    #      @section_for_detail = Section.find(params[:section].to_i)
    #    end
  end

  def hide_overdue_notice
    session['overdue_notice_cancelled'] = true
    return render :text => {:cancelled => true}.to_json
  end

  def close_dock_help
    session['dock_help_closed'] = true
    return render :text => {:closed => true}.to_json
  end

  def add_todo
    todo = Todo.new(params[:todo])
    if todo.save
      return render :text => {:success => true}.to_json
    end
    return render :text => {:success => false}.to_json
  end

  def print_roadmap_steps
    if params[:print_option]!='none' or !params[:sections].blank?
      @sections = @project.sections_in_range(params[:sections])
      render :layout => false
    else
      return redirect_to :index
    end
  end

  def update_contents
    if MarketingTextMessage.find(params[:id].to_i).update_attributes(params[:marketing_text_message])
      flash[:notice] = "Content updated successfully."
    end
    redirect_to params[:back] || :back
  end

  private
  require 'rss'
  def front_modules
    #    @messages = (Message.find_all_by_is_appropriate_and_is_admin_only(true, false, :order => 'created_at DESC', :limit => FRONT_MODULES_MESSAGES_COUNT))
    @messages = Message.appropriate.for_user(@current_user).limit_launchpad.date_wise
    rss_providers = NewsProvider.rss_providers.published.has_launchpad_feeds.sequence_wise
    @feeds = []
    rss_providers.each do |rss_provider|
      @feeds << RSS::Parser.parse(open(rss_provider.rss_link).read, false).items[0, rss_provider.front_module_count]
    end
    @feeds = @feeds.flatten.slice(0, FRONT_MODULES_RADAR_INTERNAL_COUNT)
    if SITE_BASIC_AUTH_ENABLED
      @blog_feeds = RSS::Parser.parse(open(SITE_BLOG_RSS_URL, :http_basic_authentication => [SITE_BASIC_AUTH_USER, SITE_BASIC_AUTH_PASS]).read, false).items[0, FRONT_MODULES_BLOG_INTERNAL_COUNT]
    else
      @blog_feeds = RSS::Parser.parse(open(SITE_BLOG_RSS_URL).read, false).items[0, FRONT_MODULES_BLOG_INTERNAL_COUNT]
    end
    # TODO # EXTERNAL SITE DEPENDENCY CHECK => SOCKET ERROR EXCEPTION
  rescue OpenURI::HTTPError => e
    logger.info("__RESCUE__PROJECTS__OpenURI::HTTPError__#{e}__")
  rescue SocketError => e
    logger.info("__RESCUE__PROJECTS__SocketError__#{e}__")
  rescue Exception => e
    logger.info("__RESCUE__PROJECTS__Exception__#{e}__")
  end

  def load_project
    @project = current_user.project
  end  
  def load_sections
    @sections = @current_user.project.sections.active
  end
  def load_section_to_open
    @section_number_to_open = (params[:is_section_detail].blank?) ? @current_user.project.get_lastly_worked_on_section.sequence_number : Section.find(params[:section].to_i).sequence_number
  end
  def load_recent_items
    @recent_items = @project.get_lastly_worked_on_items
  end
  def load_closely_due_section
    @closely_due_section = @project.get_closely_due_section
  end
  def load_upcoming_todos
    @upcoming_todos = @project.get_upcoming_todos
  end
  def load_content
    @roadmap_contents = MarketingTextMessage.get_roadmap_contents  
    @first_time_login = MarketingTextMessage.get_dashboard_first_time_login_content(current_user)
    @notification_banner_content =  MarketingTextMessage.get_dashboard_notification_banner_content
  end
  def set_session_variables
    session['overdue_notice_cancelled'] = false unless session['overdue_notice_cancelled']
    session['dock_help_closed'] = false unless session['dock_help_closed']
    session['notification_banner_closed'] = false unless session['notification_banner_closed']
    session['first_time_box_cacelled'] = false unless session['first_time_box_cacelled']
  end
end
