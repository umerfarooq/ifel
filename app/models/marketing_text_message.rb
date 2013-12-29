class MarketingTextMessage < ActiveRecord::Base
  validates_length_of :content, :within => 1..400, :if => :is_post_page?
  belongs_to :state
  has_many :marketing_text_links, :dependent => :destroy

  validates_presence_of :title


  def is_post_page?
    page == "messages"
  end
  def self.get_profile_contents
    contents = Hash.new
    contents[:summary] = MarketingTextMessage.find_by_page_and_location('user_profile', 'summary')
    contents[:basic_info_tooltip] = MarketingTextMessage.find_by_page_and_location('user_profile', 'basic_information_tip')
    contents[:photo_tooltip] = MarketingTextMessage.find_by_page_and_location('user_profile', 'photo_tip')
    contents[:screen_name_tooltip] = MarketingTextMessage.find_by_page_and_location('user_profile', 'screen_name_tip')
    contents[:community_profile_tooltip] = MarketingTextMessage.find_by_page_and_location('user_profile', 'community_profile_tip')
    contents[:password_tooltip] = MarketingTextMessage.find_by_page_and_location('user_profile', 'password_tip')
    return contents
  end
  def self.get_company_files_contents
    contents = Hash.new
    contents[:summary] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'file_summary')
    contents['section_1'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'starting_block_tip')
    contents['section_2'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'industry_tip')
    contents['section_3'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'prototype_tip')
    contents['section_4'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'business_structure_tip')
    contents['section_5'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'business_plan_tip')
    contents['section_6'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'funding_tip')
    contents['section_7'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'business_infrastructure_tip')
    contents['section_8'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'hiring_tip')
    contents['section_9'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'operations_tip')
    contents['section_10'] = MarketingTextMessage.find_by_page_and_location('startup_workspace', 'marketing_tip')
    return contents
  end

  def self.get_company_contents(user)
    contents = Hash.new
    if user.associated_with_ifel
      contents[:description] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_description')
      contents[:identity_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_identity_tip')
      contents[:general_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_general_information_tip')
      contents[:contact_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_contact_information_tip')
      contents[:summary_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_summary_tip')
    else
      contents[:description] = MarketingTextMessage.find_by_page_and_location('company_profile', 'description')
      contents[:identity_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'identity_tip')
      contents[:general_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'general_information_tip')
      contents[:contact_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'contact_information_tip')
      contents[:summary_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'summary_tip')  
    end   
    return contents
  end
  
  def self.get_company_contents_for_admin_tool
    contents = Hash.new
    contents[:ifel_description] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_description')
    contents[:ifel_identity_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_identity_tip')
    contents[:ifel_general_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_general_information_tip')
    contents[:ifel_contact_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_contact_information_tip')
    contents[:ifel_summary_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'ifel_summary_tip')
    contents[:description] = MarketingTextMessage.find_by_page_and_location('company_profile', 'description')
    contents[:identity_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'identity_tip')
    contents[:general_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'general_information_tip')
    contents[:contact_information_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'contact_information_tip')
    contents[:summary_tip] = MarketingTextMessage.find_by_page_and_location('company_profile', 'summary_tip')  
    return contents
  end


  def self.get_roadmap_contents
    contents = Hash.new
    contents[:dock_bar_help] = MarketingTextMessage.find_by_page_and_location('checklist', 'dock_bar_help')
    contents[:overdue_notification] = MarketingTextMessage.find_by_page_and_location('roadmap', 'overdue_notification')
    contents[:items_in_progress] = MarketingTextMessage.find_by_page_and_location('roadmap', 'items_in_progress')
    contents[:upcoming_items] = MarketingTextMessage.find_by_page_and_location('roadmap', 'upcoming_items')
    contents[:upcoming_todos] = MarketingTextMessage.find_by_page_and_location('roadmap', 'upcoming_todos')
    return contents
  end

  def self.get_roadmap_item_in_progress
    return MarketingTextMessage.find_by_page_and_location('roadmap', 'items_in_progress')
  end

  def self.get_dashboard_notification_banner_content
    contents = Hash.new
    contents[:notification_banner_first_col] = MarketingTextMessage.find_by_page_and_location('Dashboard', 'notification_banner_first_column')
    contents[:notification_banner_second_col] = MarketingTextMessage.find_by_page_and_location('Dashboard', 'notification_banner_second_col')
    contents[:notification_banner_third_col] = MarketingTextMessage.find_by_page_and_location('Dashboard', 'notification_banner_third_col')
    return contents
  end

  def self.get_dashboard_success_banner
    return MarketingTextMessage.find_by_page_and_location('Dashboard', 'progress_banner')
  end

  def self.get_dashboard_no_success_banner
    return MarketingTextMessage.find_by_page_and_location('Dashboard', 'no_progress_banner')
  end

  def self.get_dashboard_in_progress_tool_tip
    return MarketingTextMessage.find_by_page_and_location('Dashboard', 'in_progress_tool_tip')
  end

  def self.get_dashboard_first_time_login_content(current_user)
    contents = Hash.new
    contents[:title_with_text] = MarketingTextMessage.find_by_page_and_location('Dashboard', 'first_time_login_banner_with_title')
    contents[:h2_content] = MarketingTextMessage.find_by_page_and_location_and_title('Dashboard', 'first_time_login_banner', 'h2')
    contents[:h3_content] = (current_user.associated_with_ifel) ? MarketingTextMessage.find_by_page_and_location_and_title('Dashboard', 'first_time_login_banner_ifel', 'h3') : MarketingTextMessage.find_by_page_and_location_and_title('Dashboard', 'first_time_login_banner', 'h3')
    return contents
  end

end
