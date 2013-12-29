class HomeController < ApplicationController
  before_filter :set_new_design_theme, :only => :sitemap
  before_filter :require_admin, :only => [:index]
  before_filter { |c| c.active_tab=:content_tab }
  uses_tiny_mce :only => :index

  def show
    @page = params[:page]
    if @page == "home"
      return redirect_to accounts_configurations_url if current_user_is_admin?
      return redirect_to roadmap_url if current_user
      return redirect_to public_home_url
    elsif @page == "ten_steps"
      @marketing_multimedia_messages = MarketingMultimediaMessage.find_all_by_page("ten_steps").index_by(&:location)
      return render :action => @page
    elsif @page == "header" || @page == "footer" || @page == "navigation" || @page == "google_analytics"
      #      @blog = true
      return render :partial => "layouts/#{@page}"
    elsif @page == "how_it_works"
      @active_tab = :how_lauch_pad_works
      @marketing_multimedia_message = MarketingMultimediaMessage.find_by_page_and_location("how_it_works", "take_a_tour")
      return render :action => @page
    elsif @page == "admin"
      if current_user_is_admin?
        return render :action => @page
      else
        return redirect_to root_url
      end
    else
      return render :action => @page
    end
  end

  def index
    @main_banner_message = MarketingTextMessage.find_by_page_and_location('home_page','main_banner')
  end

  def sitemap
    @features = Feature.get_parents.published.sequence_wise
    @success_stories = SuccessStory.publically_available
    @biographies = Biography.for_about_us_main
    @news_articles = NewsArticle.about_us_page_articles
    @events = Event.active_events.published.date_wise
  end

  # Temporarily placed function to show FLV Player to play Guided Tours Video, untill Guided Tours panel is developed
  def guided_tour_video
    video_path = params[:video_path]
    render :partial => 'shared/flvplayer', :locals => { :video_path => video_path, :width => nil, :height => nil, :padding => nil }
  end
 
  private
  #  def home_page
  #    @new_design_theme = true
  #    if current_user_is_admin?
  #      return redirect_to community_tab_admins_url  # TODO [8/17/10 11:42 AM] => MARKETING_MESSAGES_WHEN_CREATED
  #      return redirect_to home_page_tab_admins_url
  #    elsif current_user
  #      return redirect_to projects_url
  #    else
  #      @active_tab = :home
  #      front_modules
  #      return render :action => 'public_home'
  #    end
  #  end
  #
  #  require 'rss'
  #  def front_modules
  #    @message_no_rf = MarketingTextMessage.find_by_page_and_location("public_home", "no_rss_feed")
  #    @message_no_na = MarketingTextMessage.find_by_page_and_location("public_home", "no_news_article")
  #    @message_no_tf = MarketingTextMessage.find_by_page_and_location("public_home", "no_twitter_feed")
  #    @message_no_fss = MarketingTextMessage.find_by_page_and_location("public_home", "no_featured_success_story")
  #    @featured_success_story = SuccessStory.featured.first
  #    @news_articles = NewsArticle.published.limit_launchpad.date_wise
  #    @founder_biography = Biography.founder.published.first
  #    if SITE_BASIC_AUTH_ENABLED
  #      @blog_feeds = RSS::Parser.parse(open(SITE_BLOG_RSS_URL, :http_basic_authentication => [SITE_BASIC_AUTH_USER, SITE_BASIC_AUTH_PASS]).read, false).items[0, FRONT_MODULES_BLOG_PUBLIC_COUNT]
  #    else
  #      @blog_feeds = RSS::Parser.parse(open(SITE_BLOG_RSS_URL).read, false).items[0, FRONT_MODULES_BLOG_PUBLIC_COUNT]
  #    end
  #    @twitter_feeds = RSS::Parser.parse(open(TWITTER_RSS_URL).read, false).items[0, FRONT_MODULES_TWITTER_PUBLIC_COUNT]
  #    # TODO # EXTERNAL SITE DEPENDENCY CHECK => SOCKET ERROR EXCEPTION
  #  rescue OpenURI::HTTPError => e
  #    logger.info("__RESCUE__HOME__OpenURI::HTTPError__#{e}__")
  #  rescue SocketError => e
  #    logger.info("__RESCUE__HOME__SocketError__#{e}__")
  #  rescue Exception => e
  #    logger.info("__RESCUE__HOME__Exception__#{e}__")
  #  end

end

