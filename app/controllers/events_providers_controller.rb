class EventsProvidersController < ApplicationController
  before_filter :require_admin
  before_filter(:only => [:new, :edit, :create,:update,:list]) { |c| c.active_tab = :account_tab }

  def show
    @events_provider = EventsProvider.find params[:id]
  end

  def new
    @events_provider = EventsProvider.new
  end

  def create
    
    @events_provider = EventsProvider.new(params[:events_provider])
    if (params[:events_provider][:image_display_size].blank?)
      @events_provider.image_display_size = 'small'
    else
      @events_provider.image_display_size = params[:events_provider][:image_display_size]
    end
    if @events_provider.save
      flash[:notice] = 'EventsProvider was successfully created.'
      return redirect_to list_events_url
    else
      render :action => "new"
    end
  end

  def edit
    @events_provider = EventsProvider.find params[:id] 
  end

  def destroy
    @events_provider = EventsProvider.find params[:id]
    @events_provider.destroy
    flash[:notice] = 'EvensProvider was successfully deleted.'
    return redirect_to list_events_url
  end

  def update
    #    return render :text => params[:events_provider][:image_display_size].inspect
    @events_provider = EventsProvider.find params[:id]
    if (params[:events_provider][:image_display_size].blank?)
      @events_provider.image_display_size = 'small'
    else
      @events_provider.image_display_size = params[:events_provider][:image_display_size]
    end
    if @events_provider.update_attributes(params[:events_provider])
      flash[:notice] = 'EventsProvider was successfully updated.'
      return redirect_to list_events_url
    else
      render :action => "edit"
    end
  end

  def publish
    events_provider = EventsProvider.find params[:id]
    if events_provider.publish
      flash[:notice] = "Events Provider successfully published"
    else
      flash[:notice] = "Events Provider is not publishable"
    end
    redirect_to list_events_url
  end

  def activate
    events_provider = EventsProvider.find params[:id]
    if events_provider.activate
      flash[:notice] = "Events Provider successfully activated"
    else
      flash[:notice] = "Events Provider is not activatable"
    end
    redirect_to list_events_url
  end

  def inactivate
    events_provider = EventsProvider.find params[:id]
    if events_provider.inactivate
      flash[:notice] = "Events Provider is successfully inactivated "
    else
      flash[:notice] = "Events Provider is not inactivatable"
    end
    redirect_to list_events_url
  end
end
