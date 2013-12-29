class AdminMailer < ActionMailer::Base
  add_template_helper(QuizRepliesHelper)
  default_url_options[:host] = "#{SITE_URL}"

#  def contact_us_email(contact_us)
#    subject       "[WS ContactUs] "+contact_us.subject.title.to_s
#    #    recipients    "#{CONTACT_US_EMAIL}"
#    recipients    contact_us.subject.recepient.to_s
#    bcc           "#{CONTACT_US_BCC_EMAIL}" unless CONTACT_US_BCC_EMAIL.blank?
#    from          contact_us.email
#    sent_on       Time.now
#
#    content_type  "text/html"
#    body          :to_name => "#{CONTACT_US_NAME}", :from_name => contact_us.first_name, :subject => contact_us.subject.title, :message => contact_us.message
#  end
#
#  def newsletter_subscription_email(newsletter)
#    subject       "[WS Newsletter] "+newsletter.subject.title.to_s
#    recipients    newsletter.email.to_s
#    bcc           "#{CONTACT_US_BCC_EMAIL}" unless CONTACT_US_BCC_EMAIL.blank?
#    from          newsletter.subject.recepient.to_s
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :to_name => "#{CONTACT_US_NAME}"
#  end
#
#  def quiz_reply_email(quiz_reply)
#    recipients    quiz_reply.email
#    bcc           "info@wickedstart.com"
#    from          "The Wicked Start Tech Team <noreply@wickedstart.com>"
#    subject       quiz_reply.quiz.email_subject
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :quiz_reply => quiz_reply
#  end
#
#  def partner_request_email(partner_request)
#    recipients    "info@wickedstart.com"
#    bcc           "#{CONTACT_US_BCC_EMAIL}" unless CONTACT_US_BCC_EMAIL.blank?
#    from          partner_request.email
#    subject       'New Partner Request'
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :requestee => partner_request.contact_name
#  end
#
#  def have_a_question_email(question)
#    recipients    "info@wickedstart.com"
#    bcc           "#{CONTACT_US_BCC_EMAIL}" unless CONTACT_US_BCC_EMAIL.blank?
#    from          question[:email]
#    subject       'Have A Question'
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :question => question
#  end

  def add_topic_email(topic)
    recipients    CONTACT_US_EMAIL
    bcc           "#{CONTACT_US_BCC_EMAIL}" if CONTACT_US_BCC_EMAIL
    from          topic.user.email
    subject       'Request to add a new Topic'
    sent_on       Time.now
    content_type  "text/html"
    body          :topic => topic
  end
  
  def second_day_email(user)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    #recipients    users.map {|user| "#{user.first_name} #{user.last_name} <#{user.email}>"}
    bcc           ["Umer Farooq <mail.to.umerfarooq@gmail.com>"]
    from          FROM_EMAIL
    subject       "Welcome To Workshop In Business Opportunities"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user, :host=> SITE_HOST_NAME
  end

  def send_daily_signup_report(file_path, file_name)
    recipients    CONTACT_US_EMAIL
    bcc           ["Umer Farooq <mail.to.umerfarooq@gmail.com>"]
    from          FROM_EMAIL
    subject       "Daily Signup Report"
    sent_on       Time.now
    attachment :content_type => 'application/vnd.ms-excel ', :body => File.read(file_path), :filename => file_name
  end
  
  def share_document_email(email_content, filepath)
    recipients    email_content[:to]
    bcc           "#{CONTACT_US_BCC_EMAIL}" unless CONTACT_US_BCC_EMAIL.blank?
    from          email_content[:from]
    subject       email_content[:subject]
    sent_on       Time.now
    content_type  "text/html"
    part :content_type => 'multipart/alternative' do |copy|
      copy.part :content_type => 'text/html' do |html|
        html.body = render( :file => "share_document_email.html.erb", 
          :body => { :document => email_content } )
      end
    end
    attachment    :body => File.read(filepath), :filename => email_content[:file_name] if File.exists?(filepath)
  end
  
  def message_email_to_community_expert(options)
    recipients    "#{options[:user].first_name} #{options[:user].last_name} <#{options[:user].email}>"
    from          FROM_EMAIL
    subject       "A new #{options[:section_title]} question has been asked in the WIBO.WickedStart.com community"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => options[:user], :section_title => options[:section_title], :message => options[:message_id], :site_url => SITE_URL
  end
  
  def notify_mentor_assignment_to_user(mentor, user)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "Mentor has been assigned"
    sent_on       Time.now
    content_type  "text/html"
    body          :mentor => mentor, :user => user, :site_url => SITE_URL
  end
  
  def notify_mentor_assignment_to_mentor(mentor, user)
    recipients    "#{mentor.first_name} #{mentor.last_name} <#{mentor.email}>"
    from          FROM_EMAIL
    subject       "Founder has been assigned"
    sent_on       Time.now
    content_type  "text/html"
    body          :mentor => mentor, :user => user, :site_url => SITE_URL
  end
  
  def test_email
    recipients    CONTACT_US_BCC_EMAIL
    from          FROM_EMAIL
    subject       "Test Email"
    sent_on       Time.now
    content_type  "text/html"
  end
  
end
