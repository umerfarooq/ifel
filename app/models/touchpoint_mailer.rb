class TouchpointMailer < ActionMailer::Base
  helper :application
#  default_url_options[:host] = SITE_HOST_NAME

  def touchpoint_email(project, subject, quote, paragraphs)
    recipients    "#{project.user.first_name} #{project.user.last_name} <#{project.user.email}>"
    from          FROM_EMAIL
    sent_on       Time.now
    content_type  "text/html"
    body          :project => project, :quote => quote, :paragraphs => paragraphs
    subject       subject
  end

#  def completed_item_1_01_email(project)
#    recipients    "#{project.user.first_name} #{project.user.last_name} <#{project.user.email}>"
#    from          "The Wicked Start Tech Team <noreply@wickedstart.com>"
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :project => project
#    subject       "You've completed your first action item"
#  end
#
#  def completed_item_1_04_email(project)
#    @body, @from, @sent_on, @recipients, @content_type = {:project => project}, "The Wicked Start Tech Team <noreply@wickedstart.com>", Time.now, "#{project.user.first_name} #{project.user.last_name} <#{project.user.email}>", "text/html"
#    subject "You've identified your business model"
#  end
#
#  def completed_item_1_05_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "You've identified your value proposition"
#  end
#
#  def ended_section_1_completed_item_1_08_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Your idea has potential"
#  end
#
#  def ended_items_2_01_to_2_05_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Getting experience"
#  end
#
#  def ended_section_2_completed_one_item_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "You've completed Step 2"
#  end
#
#  def completed_item_3_01_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Creating a prototype"
#  end
#
#  def ended_section_3_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Moving toward structuring your businesss"
#  end
#
#  def completed_item_4_04_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Naming a thing creates power"
#  end
#
#  def ended_section_4_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Creating your road map to profitability"
#  end
#
#  def ended_section_5_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "You're ready to get the money you need!"
#  end
#
#  def completed_item_6_04_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Finding money"
#  end
#
#  def completed_item_6_07_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Congrats on making your pitch!"
#  end
#
#  def ended_section_6_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "You've achieved a major milestone"
#  end
#
#  def ended_section_7_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Infrastructure's in place—get ready to hire"
#  end
#
#  def ended_section_8_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Get ready to get real"
#  end
#
#  def ended_section_9_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Operations are set: Time for show and tell"
#  end
#
#  def ended_all_items_email(project)
#    set_recipients_body_and_defaults_for_project(project)
#    subject "Go for liftoff!"
#  end
#
#  private
#  def set_recipients_body_and_defaults_for_project(project)
#    recipients    "#{project.user.first_name} #{project.user.last_name} <#{project.user.email}>"
#    from          "The Wicked Start Tech Team <noreply@wickedstart.com>"
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :project => project
#  end
end
