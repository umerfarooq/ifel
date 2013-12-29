class SectionsController < ApplicationController
  before_filter :require_user
  before_filter :require_payment
  before_filter { |c| c.active_tab=:launch_list }

  def index   # MOVED TO PROJECT.OVERVIEW
    #    return regirect_to root_path if @current_user.project.blank?
    ##    enable_light_box
    #    @project = @current_user.project
    #    render :layout => false
  end

  # TODO [11/3/10 1:06 PM] => REMOVE
  #  # TODO [7/17/10 3:05 AM] :=> EXTRA_CODE___REMOVE_NEXT
  #  def update
  #    #    enable_light_box
  #    @section = @current_user.project.sections.find params[:id]
  ##    @section = Section.find params[:id]
  #    if (params[:section][:do_not_show_intro])
  #      @section.update_attribute(:do_not_show_intro, (params[:section][:do_not_show_intro] == "1"))
  #      return render :text => @section.do_not_show_intro
  #    else #following code is for date updation
  #      if @section.update_attributes(params[:section])
  #        #if the section.due_date is greater than the project end data than
  #        #update the project end date as well.
  #        if @section.due_date > @section.project.end_date
  #          @section.project.end_date = @section.due_date
  #          @section.project.save
  #        end
  #        #        return render :text => @section.due_date
  #      end
  #      return render :text => @section.due_date
  #    end
  #  end


  def update
    @section = @current_user.project.sections.find(params[:id])
    @section.update_attribute(:user_answer, params[:section][:user_answer])
    #return render :json => {:success => true, :user_answer => @section.user_answer}
    redirect_to :back
  end

  def mark_show_intro
    section = @current_user.project.sections.find params[:id]
    section.update_attribute(:do_not_show_intro, (params[:section_do_not_show_intro] == "1"))
    return render :json => {:success => true, :section_do_not_show_intro => section.do_not_show_intro}
  end

  def update_due_date
    #    return render :json => {:success => false, :params => params}
    section = @current_user.project.sections.find params[:id]
    section.update_attribute(:due_date, params[:section][:due_date])
    return render :json => {:success => true, :section_id => section.id,
      :due_date_ss => section.due_date.strftime("%B %e, %Y").upcase.as_json,
      :due_date_ps => section.due_date.strftime("%m/%d/%Y").as_json,
      :due_date_rfc3339 => section.due_date.strftime("%Y-%m-%d").as_json
    }
  rescue
    return render :json => {:success => false }
  end

  def update_deadline
    section = Section.find(params[:id].to_i)
    section.update_deadline(Date.parse(params[:deadline]))
    return render :partial => 'projects/section_deadline', :locals => {:section => section} 
  end

  def show    # MOVED TO SECTION.OVERVIEW FOR OVERVIEW AND NO_NEED FOR RENDER_PARTIAL
    ##    enable_light_box
    #    #    return render :text => params.inspect
    #    @section = @current_user.project.sections.find params[:id]
    #    @section.project.update_attribute(:open_section, @section.id)
    #    if (params[:view]=='render_partial')
    ##      return render :partial => "sectionoverview"
    #      return render :partial => "section", :locals => {:section => @section}
    #    elsif (params[:view]=='render_page')
    #
    #    else
    #      #show some error
    #    end
    #    render :layout => false
  end

  # TODO [11/9/10 4:36 PM] => REFACTOR_ITEM_SECTION_NAVIGATION_FOR_NEXT_AND_PREVIOUS
  def introduction
    #    enable_light_box
    @section = @current_user.project.sections.find params[:id]
    #    @section = Section.find params[:id]
    @section.update_attribute(:is_intro_viewed, true) unless @section.is_intro_viewed
    @section.project.update_attribute(:open_section, @section.id)
    #    @preceding = edit_item_path(@section.preceding)
    #    @following = edit_item_path(@section.following)
    @preceding = item_path(@section.preceding)
    @following = item_path(@section.following)
    render :layout => false
  end

  # TODO [11/9/10 3:01 PM] => CHECK_OVERVIEW_AND_PRINT_ERBS
  def overview
    @section = @current_user.project.sections.find params[:id]
    render :layout => false
  end

  def display
    section = @current_user.project.sections.find_by_id params[:id]
    if section.blank?
      flash[:error] = "The section you requested could not be found in your project."
      return redirect_to @current_user.project
    else
      return redirect_to(:controller => 'projects', :action => 'show', :id => @current_user.project.id, :display_section => section.id)
    end
  end

  def print
    @section = @current_user.project.sections.find params[:id]
    render :layout => false
  end
  
  def print_notes
    @section = Section.find params[:id]
    render :layout => false
  end

  def update_answer
    section = @current_user.project.sections.find params[:id]
    if section.blank?
      return render :json => {:success => false}
    else
      section.update_attribute(:user_answer, params[:user_answer])
      return render :json => {:success => true, :user_answer => section.user_answer}
    end
  end

  def flvplayer
    video_path = params[:video_path]
    render :partial => 'shared/flvplayer', :locals => { :video_path => video_path, :width => '640', :height => '396', :padding => nil }
  end

end
