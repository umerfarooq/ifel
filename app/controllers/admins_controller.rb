class AdminsController < ApplicationController

  uses_tiny_mce :only => [:startup_workspace_tab, :roadmap_tab]
  before_filter { |c| c.active_tab=:content_tab }
  before_filter(:only=>:community_tab) { |c| c.active_tab=:account_tab }
  before_filter(:only=>[:my_files_tab, :action_items]) { |c| c.active_tab=:checklist }
  before_filter :require_admin
  
  def home_page_tab
    return redirect_to home_page_path
    @marketing_message = MarketingTextMessage.find_by_title("Home Page Introduction") || MarketingTextMessage.new
    @marketing_message_general = MarketingTextMessage.find_by_title("Founder Message") || MarketingTextMessage.new
    #    @questions = Question.all
  end

  def launch_pad_tab #DONE
    return redirect_to root_path
    @marketing_message = MarketingTextMessage.find_by_title("Launch Pad Intro Message") || MarketingTextMessage.new
    @marketing_message_general = MarketingTextMessage.find_by_title("Launch Pad General Message") || MarketingTextMessage.new
  end

  def community_tab
    #@marketing_message = MarketingTextMessage.find_by_title("Community Page General Message") || MarketingTextMessage.new
    @marketing_text_message = MarketingTextMessage.find_by_page_and_location("messages", "post_question")
    @topic = Topic.new
    @topics = Topic.all
    @errors = ""
    
#    @post_message_content.update_attributes(params[:marketing_text_message])
#    return redirect_to list_message_categories_url
#    @marketing_message = MarketingTextMessage.find_by_title("Community Page General Message") || MarketingTextMessage.new
#    #get community categories
#    @message_category = MessageCategory.new
#    @message_categories = MessageCategory.all
  end


  def files_tab
    return redirect_to list_documents_url
    return redirect_to list_document_categories_url
    @marketing_message = MarketingTextMessage.find_by_title("My Files Page General Message") || MarketingTextMessage.new
    #get files categories
    @files_category = DocumentCategory.new
    @files_categories = DocumentCategory.all
  end

  def resources_tab #DONE
    return redirect_to root_path
    @marketing_message = MarketingTextMessage.find_by_title("Resources Page General Message") || MarketingTextMessage.new
  end

  def radar_tab
    return redirect_to list_news_articles_url
    @marketing_message = MarketingTextMessage.find_by_title("ON THE RADAR") || MarketingTextMessage.new
    #get news categories
    #get wickedstart news
    @news_category = NewsCategory.new
    @news_categories = NewsCategory.all
    @news_items = NewsItem.all
  end

  def inspiration_tab
    return redirect_to list_success_stories_url
    @marketing_message = MarketingTextMessage.find_by_title("READ OUR LATEST SUCCESS STORIES") || MarketingTextMessage.new
    #get inspirational stories
    @success_stories = SuccessStory.all
  end

  def about_us_tab
    @message_main = MarketingTextMessage.find_by_page_and_location("about_us", "main")
  end

  def partners_tab
    return redirect_to list_partners_path
  end

  def faqs_tab
    return redirect_to faq_categories_url
    @marketing_message = MarketingTextMessage.find_by_title("FAQS") || MarketingTextMessage.new
    #get faqs
    @faqs = Faq.all
  end

  def quizzes_tab
    return redirect_to quizzes_url
  end

  def billing_tab
    
  end

  def reporting_tab
    return redirect_to report_list_path
  end

  def features_tab
    return redirect_to list_features_url
  end

  def common_questions_tab
    return redirect_to list_common_questions_path
  end

  def industry_tab
    return redirect_to industries_path
    #@industry = Industry.title_wise
  end

  def my_files_tab
    @startup_workspace_contents = Hash.new
    @startup_workspace_contents[:company_files] = MarketingTextMessage.get_company_files_contents
  end

  def company_tab
    @startup_workspace_contents = Hash.new
    @startup_workspace_contents[:company] = MarketingTextMessage.get_company_contents_for_admin_tool
  end

  def roadmap_tab
    @roadmap_contents = Hash.new
    @roadmap_contents = MarketingTextMessage.get_roadmap_contents
    
  end

  def dashboard_tab
#    @notification_banner_first_col =  MarketingTextMessage.get_dashboard_notification_banner_first_col
#    @notification_banner_second_col = MarketingTextMessage.get_dashboard_notification_banner_second_col
#    @notification_banner_third_col = MarketingTextMessage.get_dashboard_notification_banner_third_col
    @notification_banner_content =  MarketingTextMessage.get_dashboard_notification_banner_content
    @success_banner = MarketingTextMessage.get_dashboard_success_banner
    @no_success_banner  = MarketingTextMessage.get_dashboard_no_success_banner
    @tool_tip_text  = MarketingTextMessage.get_dashboard_in_progress_tool_tip
    @first_time_login = MarketingTextMessage.get_dashboard_first_time_login_content
    
  end
end
