class NewsItemsController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
  before_filter { |c| c.active_tab=:on_the_radar }

  require 'rss'
  def index
    @wp_limit = 3
    @message_main = MarketingTextMessage.find_by_page_and_location("on_the_radar", "main")
    @message_no_wp = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_white_paper")
    @message_no_na = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_news_article")
    @message_no_rf = MarketingTextMessage.find_by_page_and_location("on_the_radar", "no_rss_feed")
    if current_user
      @radar_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"ON THE RADAR",:state_id => 1})
      #    return render :text => "H3R3"
      @radar_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"ON THE RADAR",:state_id => 1})
      @query = params[:query]
      if @query == 'white_papers'
        @white_papers = WhitePaper.find_all_by_is_active(true, :order => "created_at DESC")
        #        @white_papers = WhitePaper.find_all_by_is_active_and_is_public(true, false)
      else
        @rss_limit = 3
        @wp_maxcount = WhitePaper.count(:conditions => [ "is_active = ?", true])
        #        @wp_count = WhitePaper.count(:conditions => [ "is_active = ? AND is_public = ?", true, false])
        @white_papers = WhitePaper.find_all_by_is_active(true, :limit => @wp_limit, :order => "created_at DESC")
        #        @white_papers = WhitePaper.find_all_by_is_active_and_is_public(true, false, :limit => @wp_limit)
        #        @feeds = NewsItem.parseFeed('http://feeds.feedburner.com/OrderOfMagnitudeCeos', 5)
#        @feed_hash[0][:provider_name] = "INC"
#        @feed_hash[0][:feeds] = getRssFeeds('http://feeds.feedburner.com/inc/headlines', @rss_limit)
#        @feed_hash[1][:provider_name] = "Order of Magnitude"
#        @feed_hash[1][:feeds] = getRssFeeds('http://feeds.feedburner.com/OrderOfMagnitudeCeos', @rss_limit)
#        feedinc = getRssFeeds('http://feeds.feedburner.com/OrderOfMagnitudeCeos', @rss_limit)
#        feedinc = getRssFeeds('http://www.inc.com/rss.xml', @rss_limit)
#        return render :text => feedinc[0].title.inspect
#        return render :text => [feedinc[0].guid, feedinc[0].date, feedinc[0].title, feedinc[0].description]
#        @rss_providers = NewsProvider.find_all_by_is_active_and_is_rss_provider(true, true);
        @rss_providers = NewsProvider.find_all_by_is_rss_provider_and_state_id(true, State.find_by_name('publish').id)
#        RAILS_DEFAULT_LOGGER.debug "1__$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
#        RAILS_DEFAULT_LOGGER.debug @rss_providers[1].inspect
#        RAILS_DEFAULT_LOGGER.debug "2__$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
#        return render :json => RSS::Parser.parse(open("http://feeds.feedburner.com/inc/headlines").read, false).items[0..@rss_limit-1]
        @feeds = []
        @rss_providers.each do |rss_provider|
#          @feeds[rss_provider.id] = getRssFeeds(rss_provider.rss_link, @rss_limit)
          @feeds[rss_provider.id] = RSS::Parser.parse(open(rss_provider.rss_link).read, false).items[0..@rss_limit-1]
#          rss_provider[:feeds] = getRssFeeds(rss_provider.rss_link, @rss_limit)
        end
#        return render :json => @feeds
#        return render :json => @feeds[@rss_providers[1].id]
#        RAILS_DEFAULT_LOGGER.debug "3__$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
#        RAILS_DEFAULT_LOGGER.debug @feeds[@rss_providers[0].id].inspect
#        RAILS_DEFAULT_LOGGER.debug "4__$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
#        return render :text => @feeds[@rss_providers[0].id].inspect
#        RAILS_DEFAULT_LOGGER.debug "5__$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
#        return render :text => @feeds[0]
      end
    else
      #    @message_radar = MarketingTextMessage.find_by_page_and_location("on_the_radar", "on_the_radar")
      @radar_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"ON THE RADAR",:state_id => 1})
      @query = params[:query]
      if @query == 'white_papers'
        @white_papers = WhitePaper.find_all_by_is_active_and_is_public(true, true, :order => "created_at DESC")
        #        @white_papers = NewsItem.find_all_by_news_category_id((NewsCategory.find_by_title("White Papers")).id)
      else
        @wp_maxcount = WhitePaper.count(:conditions => [ "is_active = ? AND is_public = ?", true, true])
#        return render :text => "#{@wp_limit} is #{@wp_limit.class}, and #{@wp_maxcount} is #{@wp_maxcount.class}"
        @white_papers = WhitePaper.find_all_by_is_active_and_is_public(true, true, :limit => @wp_limit, :order => "created_at DESC")
#        @news_articles = NewsArticle.find_all_by_is_active_and_is_public(true, true)
        @news_articles = NewsArticle.find_all_by_is_active_and_is_public(true, true, :order => 'news_date DESC')
        #        @white_papers = NewsItem.latest_white_papers(3)
        #        @white_paper_count = NewsItem.find_all_by_news_category_id((NewsCategory.find_by_title("White Papers")).id).count
        #        @news_articles = NewsItem.find_all_by_news_category_id((NewsCategory.find_by_title("News Articles")).id)
        #      @press_releases = NewsItem.find_all_by_news_category_id((NewsCategory.find_by_title("Press Releases")).id)
      end
    end
  end

  def show
    @news_item = NewsItem.find_by_id(params[:id])
  end

  def new
    #    return render :xml => params
    @type = params[:type]
    if @type == "news_article"
      @news_article = NewsArticle.new
    elsif @type == "white_paper"
      @white_paper = WhitePaper.new
    else
      redirect_to root_url
    end
    #    @news_item = NewsItem.new
  end

  def create
    #    return render :xml => params
    @type = params[:type]
    if @type == "news_article"
      params[:news_article][:summary].gsub!(/<br>$/, "")
      @news_article = NewsArticle.new(params[:news_article])
      @news_article.news_provider = NewsProvider.find_by_id(params[:news_article][:news_provider_id])
      @news_article.is_public = (params[:news_article][:is_public] == "1")
      @news_article.is_active = true
      @news_article.state_id = (State.find_by_title("create")).id
      if @news_article.save
        flash[:notice] = "News article successfully added."
        redirect_to root_url
      else
        render :action => 'new'
      end
    elsif @type == "white_paper"
      params[:white_paper][:summary].gsub!(/<br>$/, "")
      @white_paper = WhitePaper.new(params[:white_paper])
      @white_paper.is_public = (params[:white_paper][:is_public] == "1")
      @white_paper.is_active = true
      @white_paper.state_id = (State.find_by_title("create")).id
      #      return render :xml => @white_paper
      if @white_paper.save
        flash[:notice] = "News item successfully added."
        redirect_to root_url
      else
        render :action => 'new'
      end
    else
      @news_item = NewsItem.new(params[:news_item])
      @news_item.news_category = NewsCategory.find_by_id(params[:news_item][:news_category_id])
      @news_item.news_provider = NewsProvider.find_by_id(params[:news_item][:news_provider_id])
      if @news_item.save
        flash[:notice] = "News item successfully added."
        redirect_to root_url
      else
        render :action => 'new'
      end
    end
  end

  #################################################################################################
  #################################################################################################
  #################################################################################################
  def edit
    @news_item = NewsItem.find_by_id(params[:id])
  end

  def update
    @news_item = NewsItem.find_by_id(params[:id])
    if @news_item.update_attributes(params[:news_item])
      flash[:notice] = "New updated successfully."
      redirect_to '/admins/radar_tab'
    else
      render :action => 'edit'
    end
  end

#  def destroy
#    @faq = Faq.find_by_id(params[:id])
#    # @biography.destroy
#    @faq.status = "destroyed"
#    if @faq.save
#      flash[:notice] = 'Faq marked destroyed.'
#    else
#      flash[:notice] = 'Faq cannot be marked destroyed.'
#    end
#    redirect_to(root_path)
#  end

  def change_state
#    return render :text => params.inspect
    @news_item = NewsItem.find_by_id(params[:id])
    @news_item.state = State.find_by_title(params[:state])
    if @news_item.save
    else
    end
    redirect_to '/admins/radar_tab'
  end

  private
  require 'rss'
  def getRssFeeds(url, limit)
    rss = RSS::Parser.parse(open(url).read, false).items[0..limit-1]
  end
end
