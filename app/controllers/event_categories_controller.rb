class EventCategoriesController < ApplicationController
  before_filter(:only => [:new, :edit, :create,:update,:list]) { |c| c.active_tab = :account_tab }
  
  def index
#    @event_categories = EventCategory.public_categories
  end
  def new
    @event_category = EventCategory.new
  end
  def edit
    @event_category = EventCategory.find_by_id(params[:id])
  end
  def update
    @event_category = EventCategory.find_by_id(params[:id])
    if @event_category.update_attributes(params[:event_category])
      flash[:notice] = "Event Category successfully updated."
      redirect_to list_events_url
    else
      render :action => 'edit'
    end
  end

  def create
    @event_category = EventCategory.new(params[:event_category])
    if @event_category.save
      flash[:notice] = "Event Category successfully added."
      redirect_to list_events_url
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @event_category = EventCategory.find_by_id(params[:id])
    if @event_category.destroy
      flash[:success] = "Event Category is deleted."
    else
      flash[:notice] = "Event Category can't be deleted."
    end
    return redirect_to :back
  end
  
  def show
    @event_category = EventCategory.find_by_id(params[:id])
  end

  def publish
    event_category = EventCategory.find params[:id]
    if event_category.publish
      flash[:notice] = "Event Category successfully published"
    else
      flash[:notice] = "Event Category is not publishable"
    end
    redirect_to list_events_url
  end

  def activate
    event_category = EventCategory.find params[:id]
    if event_category.activate
      flash[:notice] = "Event Category successfully activated"
    else
      flash[:notice] = "Event Category is not activatable"
    end
    redirect_to list_events_url
  end

  def inactivate
    event_category = EventCategory.find params[:id]
    if event_category.inactivate
      flash[:notice] = "Event Category successfully inactivated"
    else
      flash[:notice] = "Event Category is not inactivatable"
    end
    redirect_to list_events_url
  end
end
