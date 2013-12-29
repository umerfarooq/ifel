class DashboardsController < ApplicationController
  before_filter :require_user
  before_filter :require_payment
  before_filter { |c| c.active_tab=:startup_workspace }
  before_filter :set_new_design_theme
  before_filter :load_project, :only=>[:index]
  before_filter :load_content, :only=>[:index]
  

  def index
    return redirect_to roadmap_path #Hiding out Dashboard
    session['first_time_box_cacelled'] = false unless session['first_time_box_cacelled']
    session['progress_banner_closed'] = false unless session['progress_banner_closed']
    session['notification_banner_closed'] = false unless session['notification_banner_closed']
    #return render :text => 'Yes'

#    Most trending Topics
     @topics = Topic.top_trending
#    News Feed
     @news_feeds = Feed.news_feeds.future_feeds.date_wise
#     @news_feeds = NewsArticle.published.date_wise | NewsArticle.featured.date_wise
#    Resources
     @resources = Resource.top_trending()
#    Banner masseges
     @notification_banner_first_col =  MarketingTextMessage.get_dashboard_notification_banner_first_col
     @notification_banner_second_col = MarketingTextMessage.get_dashboard_notification_banner_second_col
     @notification_banner_third_col = MarketingTextMessage.get_dashboard_notification_banner_third_col
     @success_banner = MarketingTextMessage.get_dashboard_success_banner
     @no_success_banner  = MarketingTextMessage.get_dashboard_no_success_banner
     @first_time_login = MarketingTextMessage.get_dashboard_first_time_login_content
#    Events
     
     @events = (Event.future_events.published.date_wise + Feed.event_feeds.future_event_feeds.date_wise).sort_by {|obj| obj.event_start_time}


  end

  def update_banner_notifications
      if MarketingTextMessage.find(params[:id].to_i).update_attributes(params[:marketing_text_message])
      flash[:success] = "Dashboard Banner notification updated successfully."
    end
    redirect_to params[:back] || :back
  end
  
  def load_project
    @project = current_user.project
  end
  
  def cancel_notification_box
    session['first_time_box_cacelled'] = true
    return render :text => {:cancelled => true}.to_json
  end

  def cancel_progress_banner
    session['progress_banner_closed'] = true
    return render :text => {:cancelled => true}.to_json
  end

  def cancel_notification_banner
    session['notification_banner_closed'] = true
    return render :text => {:cancelled => true}.to_json
  end

  def resource_category_filter
    resources = Resource.top_trending_resources_by_section(params[:section_id])
    if request.xhr?
      return render :partial => "resources", :locals => {:resources => resources}
    end
  end

  def load_content
    @tool_tip_contents = MarketingTextMessage.get_dashboard_in_progress_tool_tip
    @roadmap_contents = MarketingTextMessage.get_roadmap_contents
  end
end
