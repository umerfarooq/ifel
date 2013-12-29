class NewsArticlesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :require_admin, :except => [:index, :show]
  before_filter(:only => [:index, :show]) { |c| c.active_tab=:on_the_radar }
  before_filter :set_new_design_theme, :only => [:index, :show]
  before_filter(:only => [:new, :edit, :create,:update,:list]) { |c| c.active_tab = :account_tab }
  
  
  def index
    #    if current_user.present?
    #      @news_articles = Feed.news_feeds.future_feeds.date_wise
    #    else
    @news_articles = NewsArticle.published.date_wise | NewsArticle.featured.date_wise
    @news_articles = @news_articles.sort { |a,b| b.news_date <=> a.news_date  } unless @news_articles.blank?
    #    end  
    @upcomming_events = Event.aboutus_sidebar_events
    @featured_news_articles = NewsArticle.shuffle_featured_articles 3
  end

  require 'rss'
  def index_bak
    @message_main = MarketingTextMessage.find_by_page_and_location("on_the_radar", "main")
    @message_no_wp = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_white_paper")
    @message_no_na = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_news_article")
    @message_no_rf = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_rss_feed")
    if current_user.blank?
      @white_paper_max_count = WhitePaper.published.for_public.count
      @white_papers = WhitePaper.published.for_public.limit_radar.sequence_wise
      @news_articles = NewsArticle.published.date_wise
    else
      @white_paper_max_count = WhitePaper.published.count
      @white_papers = WhitePaper.published.limit_radar.sequence_wise
      @rss_providers = NewsProvider.rss_providers.published.has_radar_feeds.sequence_wise
      @feeds = []
      @rss_providers.each do |rss_provider|
        #        @feeds[rss_provider.id] = RSS::Parser.parse(open(rss_provider.rss_link).read, false).items[0, rss_provider.feed_count]
        #        @feeds.concat RSS::Parser.parse(open(rss_provider.rss_link).read, false).items.collect{|p|{:pubDate=>p.pubDate,:description=>Utilities.white_list_custom(p.description).slice(0, 250),:title=>p.title,:rss_provider=>rss_provider,:link=>p.link} unless p.title == 'Advertisement:'}.compact.sort_by { |f| f[:pubDate]}
        @feeds = @feeds + RSS::Parser.parse(open(rss_provider.rss_link).read, false).items.collect do |feed|
          {
            :rss_provider => rss_provider,
            :title => feed.title,
            :pubDate => feed.pubDate,
            #:description => Utilities.white_list_custom(feed.description).slice(0, 250),
            #:description => truncate(strip_tags(feed.description), :length => ON_THE_RADAR_FEED_LENGTH), # In View
            :description => feed.description,
            :link => feed.link
          } unless feed.title == 'Advertisement:'
        end
      end
      @feeds.compact!.sort!{ |x, y| y[:pubDate] <=> x[:pubDate] }
      # TODO [10/30/10 3:38 AM] => WILL_PAGINATE ?
      #      @feeds = paginate_collection(@feeds.sort_by{|f| f[:pubDate]}.reverse!,10,params[:page] || 1)
      @feeds = paginate_collection(@feeds, 10, params[:page] || 1)
      puts @feeds.length
    end
  end

  def show
    @news_article = NewsArticle.find params[:id]
    @upcomming_events = Event.aboutus_sidebar_events
    return redirect_to @news_article.url unless @news_article.internal?
  end

  def display
    @news_article = NewsArticle.find params[:id]
  end

  def new
    @news_article = NewsArticle.new
  end

  def create
    @news_article = NewsArticle.new(params[:news_article])
    @news_article.news_provider = NewsProvider.find(params[:news_article][:news_provider_id]) rescue nil
    @news_article.is_internal = (params[:news_article][:is_internal] == "1")
    if @news_article.save
      flash[:notice] = "News article successfully added."
      return redirect_to list_news_articles_url
    else
      render :action => 'new'
    end
  end

  def destroy
    @news_article = NewsArticle.find params[:id]
    @news_article.destroy
    flash[:notice] = 'NewsArticle was successfully deleted.'
    return redirect_to list_news_articles_url
  end

  def edit
    @news_article = NewsArticle.find params[:id]
  end

  def update
    @news_article = NewsArticle.find params[:id]
    @news_article.news_provider = NewsProvider.find(params[:news_article][:news_provider_id]) unless params[:news_article][:news_provider_id].blank?
    @news_article.is_internal = (params[:news_article][:is_internal] == "1") unless params[:news_article][:is_internal].blank?
    if @news_article.update_attributes(params[:news_article])
      flash[:notice] = "News article successfully updated."
      return redirect_to list_news_articles_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @news_article = NewsArticle.find params[:id]
    @news_article.destroy
    flash[:notice] = 'NewsArticle was successfully deleted.'
    return redirect_to list_news_articles_url
  end

  def list
    #    @message_main = MarketingTextMessage.find_by_page_and_location("on_the_radar", "main")
    #    @message_no_wp = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_white_paper")
    #    @message_no_na = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_news_article")
    #    @message_no_rf = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_rss_feed")
    @events_providers = EventsProvider.title_wise
    @news_providers = NewsProvider.sequence_wise
    @news_articles = NewsArticle.date_wise
    @white_papers = WhitePaper.sequence_wise
    @events = Event.date_wise
    @promotions = Promotion.date_wise
    @event_categories = EventCategory.title_wise
  end

  def publish
    news_article = NewsArticle.find params[:id]
    if news_article.publish
      flash[:notice] = "News Article successfully published"
    else
      flash[:notice] = "News Article is not publishable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def featurify
    news_article = NewsArticle.find params[:id]
    if news_article.featurify
      flash[:notice] = "News Article successfully featurified"
    else
      flash[:notice] = "News Article is not featurifiable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def activate
    news_article = NewsArticle.find params[:id]
    if news_article.activate
      flash[:notice] = "News Article successfully activated"
    else
      flash[:notice] = "News Article is not activatable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end

  def inactivate
    news_article = NewsArticle.find params[:id]
    if news_article.inactivate
      flash[:notice] = "News Article successfully inactivated"
    else
      flash[:notice] = "News Article is not inactivatable"
    end
    return redirect_to(request.env['HTTP_REFERER'] || list_news_articles_url)
  end


  private

  def paginate_collection(collection, per_page,current_page)
    current_page=current_page.to_i
    if current_page==1
      @next='<span class="disable-new">New &gt;&gt;</span>'
    else
      @next='<a href="'+request.path_info+'?page='+(current_page-1).to_s+'">New &gt;&gt;</a>'
    end
    if (current_page*per_page)>(collection.length)
      @prev='<span class="disable-old">&lt;&lt; Old</span>'
    else
      @prev='<a href="'+request.path_info+'?page='+(current_page+1).to_s+'">&lt;&lt; Old</a>'
    end
    collection[(per_page*(current_page-1))..((current_page*per_page)-1)]
  end

end
