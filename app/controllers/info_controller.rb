require 'rss'
class InfoController < ApplicationController
  before_filter :set_new_design_theme
  before_filter :redirect_nyu_user, :except => [:public_home, :search, :ten_steps]
  
  def public_home
    return redirect_to accounts_configurations_url if current_user_is_admin?
    return redirect_to roadmap_url if current_user and !current_user.is_blocked
    @active_tab = :home
    @success_story = SuccessStory.for_home_page
    @message_main = MarketingTextMessage.find_by_page_and_location("public_home", "main")
    @news_articles = NewsArticle.home_page_articles
    @featured_news_articles = NewsArticle.shuffle_featured_articles 4
    @upcomming_events = Event.home_page_events
    @regular_promotions = Promotion.regular_kind_of.published.date_wise
    @partner_promotions = Promotion.partner_kind_of.featured.date_wise
    @banner_content = MarketingTextMessage.find_by_page_and_location('home_page', 'main_banner')
    @features = Feature.for_index
    @multimedia = MarketingMultimediaMessage.find_by_page_and_location('why_wicked_start','main')
    @blog_post = BlogFeed.first
  end

  def about_us
    @active_tab = :about_us
    @biographies = Biography.for_about_us_main
    @news_articles = NewsArticle.about_us_page_articles
    @twitter_feeds = RSS::Parser.parse(open(TWITTER_RSS_URL).read, false).items[0, FRONT_MODULES_TWITTER_PUBLIC_COUNT]
  end

  def search
    @query = params[SEARCH_FIELD.to_sym]
    @search_results = ThinkingSphinx.search(
      @query,
      :classes => [Resource, Example, TemplateDocument, Comment, Message],
      :page => params[:page],
      :per_page => SEARCH_PAGINATION_COUNT, :retry_stale => true)
    SearchTerm.searched(@query, request.referer, 'public')
    #    return render :action => 'comming_soon'
  end

  def privacy_policy
  end

  def terms_and_conditions
  end

  def comming_soon
  end

  def ten_steps
    @marketing_multimedia_messages = MarketingMultimediaMessage.find_all_by_page("ten_steps").index_by(&:location)
  end

  def questionnaire
    #     render :layout => false
  end

  def community_guidelines
  end

#  private
#  require 'rss'
#  def front_modules
#    #    @message_no_rf = MarketingTextMessage.find_by_page_and_location("public_home", "no_rss_feed")
#    #    @message_no_na = MarketingTextMessage.find_by_page_and_location("public_home", "no_news_article")
#    #    @message_no_tf = MarketingTextMessage.find_by_page_and_location("public_home", "no_twitter_feed")
#    #    @message_no_fss = MarketingTextMessage.find_by_page_and_location("public_home", "no_featured_success_story")
#    #    @featured_success_story = SuccessStory.featured.first
#    #    @news_articles = NewsArticle.published.limit_launchpad.date_wise
#    #    @founder_biography = Biography.founder.published.first
#    all_blogs_feeds = []
#    recent_post_per_blog = {}
#    if SITE_BASIC_AUTH_ENABLED
#      SITE_BLOGS_LINKS.each_with_index do |site_blog, index|
#        return all_blogs_feeds = RSS::Parser.parse(open(site_blog, :http_basic_authentication => [SITE_BASIC_AUTH_USER, SITE_BASIC_AUTH_PASS]).read, false).items
#        recent_post_per_blog[SITE_BLOGS[index]] = all_blogs_feeds.sort_by { |a| a.pubDate.to_datetime }.last      
#      end
#    else
#      SITE_BLOGS_LINKS.each_with_index do |site_blog, index|
#        all_blogs_feeds = RSS::Parser.parse(open(site_blog).read, false).items
#        recent_post_per_blog[SITE_BLOGS[index]] = all_blogs_feeds.sort_by { |a| a.pubDate.to_datetime }.last         
#      end
#    end
#    
#    
#      
#    
#    return recent_post_per_blog.length.to_s
#        
#    #    @twitter_feeds = RSS::Parser.parse(open(TWITTER_RSS_URL).read, false).items[0, FRONT_MODULES_TWITTER_PUBLIC_COUNT]
#    # TODO # EXTERNAL SITE DEPENDENCY CHECK => SOCKET ERROR EXCEPTION
#  rescue OpenURI::HTTPError => e
#    logger.info("__RESCUE__HOME__OpenURI::HTTPError__#{e}__")
#  rescue SocketError => e
#    logger.info("__RESCUE__HOME__SocketError__#{e}__")
#  rescue Exception => e
#    logger.info("__RESCUE__HOME__Exception__#{e}__")
#  end

  

end
