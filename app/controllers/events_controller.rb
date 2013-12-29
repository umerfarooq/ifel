class EventsController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter(:only => [:index, :show]) { |c| c.active_tab=:on_the_radar }
  before_filter :set_new_design_theme, :only => [:index, :show]
  before_filter(:only => [:new, :edit, :create,:update,:list]) { |c| c.active_tab = :account_tab }

  def index
    #@events_with_images = Event.for_about_us_with_images
    @event_categories = EventCategory.public_categories
    @latest_news_article = (current_user.present?) ? Feed.news_feeds.date_wise.no_of_records(5) : NewsArticle.published.date_wise.no_of_records(5)
    @feeds = Feed.event_feeds.future_feeds.date_wise
    @recent_events = Event.recent_events
  end

  def show
    @event = Event.find params[:id]
    #    @latest_news_article = NewsArticle.events_page_article
    @latest_event = Event.latest_event_other_than_focused_one(params[:id].to_i)
  end

  def display
    @event = Event.find params[:id]
  end

  def new
    @event = Event.new
  end

  def create
    options = Event.do_time_formations(params[:event])
    #    @event_start_time = options[:event_start_time]
    #    @event_end_time = options[:event_end_time]
    @event = Event.new(options)
    @event.event_category = EventCategory.find(params[:event][:event_category_id]) rescue nil
    #    if (params[:event][:image_display_size].blank?)
    #      @event.image_display_size = 'small'
    #    else
    #      @event.image_display_size = params[:event][:image_display_size]
    #    end
    @event = @event.validate_start_and_end_date
    if @event.errors.blank?
      if @event.save
        flash[:notice] = "Event successfully added."
        return redirect_to list_events_url
      end
    end
    render :action => 'new'
  end

  def edit
    @event = Event.find params[:id]
  end

  def update
    @event = Event.find params[:id]
    options = Event.do_time_formations(params[:event])
    options[:event_category] = EventCategory.find(params[:event][:event_category_id])
    #    if (params[:event][:image_display_size].blank?)
    #      @event.image_display_size = 'small'
    #    else
    #      @event.image_display_size = params[:event][:image_display_size]
    #    end
    #    @event = @event.validate_start_and_end_date(options)
    if @event.errors.blank?
      if @event.update_attributes(options)
        flash[:notice] = "Event updated successfully."
        return redirect_to list_events_url
      end
    end
    render :action => 'edit'
  end

  def destroy
    @event = Event.find params[:id]
    @event.destroy
    flash[:notice] = 'Event was successfully deleted.'
    return redirect_to list_events_url
  end
  
  def list
    @events_providers = EventsProvider.title_wise
    @events = Event.date_wise
    @event_categories = EventCategory.title_wise
  end

  def featurify
    event = Event.find params[:id]
    if event.featurify
      flash[:notice] = "Event successfully featurified"
    else
      flash[:notice] = "Event is not featurifiable"
    end
    redirect_to list_events_url
  end

  def publish
    event = Event.find params[:id]
    if event.publish
      flash[:notice] = "Event successfully published"
    else
      flash[:notice] = "Event is not publishable"
    end
    redirect_to list_events_url
  end

  def activate
    event = Event.find params[:id]
    if event.activate
      flash[:notice] = "Event successfully activated"
    else
      flash[:notice] = "Event is not activatable"
    end
    redirect_to list_events_url
  end

  def inactivate
    event = Event.find params[:id]
    if event.inactivate
      flash[:notice] = "Event successfully inactivated"
    else
      flash[:notice] = "Event is not inactivatable"
    end
    redirect_to list_events_url
  end

  def pull_feeds
    system "cd /home/ibox/RailsProjects/Wickedstart/trunk/code && /opt/ruby-enterprise-1.8.7-2011.03/bin/rake event:pull_feeds" if Rails.env == 'development'
    system "cd /var/rails/apps/wickedstart/current && /usr/local/bin/rake event:pull_feeds" if Rails.env == 'production'
    flash[:notice] = 'System is Pulling the Feeds'
    redirect_to list_events_url
  end
end