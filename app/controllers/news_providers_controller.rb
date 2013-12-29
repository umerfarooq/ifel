class NewsProvidersController < ApplicationController
  before_filter :require_admin
  before_filter(:only => [:new, :edit, :create,:update]) { |c| c.active_tab = :account_tab }

  def show
    @news_provider = NewsProvider.find params[:id]
  end

  def new
    @news_provider = NewsProvider.new
  end

  def create
    @news_provider = NewsProvider.new(params[:news_provider])
    if (params[:news_provider][:image_display_size].blank?)
      @news_provider.image_display_size = 'small'
    else
      @news_provider.image_display_size = params[:news_provider][:image_display_size]
    end
    @news_provider.is_rss_provider = (params[:news_provider][:is_rss_provider] == "1")
    if @news_provider.save
      flash[:notice] = 'NewsProvider was successfully created.'
      return redirect_to list_news_articles_url
    else
      render :action => "new"
    end
  end

  def edit
    @news_provider = NewsProvider.find params[:id]
  end

  def destroy
    @news_provider = NewsProvider.find params[:id]
    @news_provider.destroy
    flash[:notice] = 'NewsProvider was successfully deleted.'
    return redirect_to list_news_articles_url
  end

  def update
#    return render :text => params[:news_provider][:image_display_size].inspect
    @news_provider = NewsProvider.find params[:id]
    @news_provider.is_rss_provider = (params[:news_provider][:is_rss_provider] == "1") unless params[:news_provider][:is_rss_provider].blank?
    if (params[:news_provider][:image_display_size].blank?)
      @news_provider.image_display_size = 'small'
    else
      @news_provider.image_display_size = params[:news_provider][:image_display_size]
    end
    if @news_provider.update_attributes(params[:news_provider])
      flash[:notice] = 'NewsProvider was successfully updated.'
      return redirect_to list_news_articles_url
    else
      render :action => "edit"
    end
  end

  def publish
    news_provider = NewsProvider.find params[:id]
    if news_provider.publish
      flash[:notice] = "News Provider successfully published"
    else
      flash[:notice] = "News Provider is not publishable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def activate
    news_provider = NewsProvider.find params[:id]
    if news_provider.activate
      flash[:notice] = "News Provider successfully activated"
    else
      flash[:notice] = "News Provider is not activatable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def inactivate
    news_provider = NewsProvider.find params[:id]
    if news_provider.inactivate
      flash[:notice] = "News Provider successfully inactivated"
    else
      flash[:notice] = "News Provider is not inactivatable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def move_up
    news_provider = NewsProvider.find params[:id]
    if news_provider.move_up
      flash[:notice] = "News Provider successfully moved up"
    else
      flash[:notice] = "News Provider could not be moved up"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def move_down
    news_provider = NewsProvider.find params[:id]
    if news_provider.move_down
      flash[:notice] = "News Provider successfully moved down"
    else
      flash[:notice] = "News Provider could not be moved down"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

end
