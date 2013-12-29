class UserMailer < ActionMailer::Base
  default_url_options[:host] = SITE_URL

  def password_reset_email(user)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "Forgot Username or Password Request"
    content_type  "text/html"
    sent_on       Time.now
    #    body          :first_name => user.first_name, :change_password_url => change_password_url(user.perishable_token)
    #    body          :user_name => user.login, :first_name => user.first_name, :change_password_url => SITE_URL_FOR_MAILS+change_password_path(user.perishable_token)
    body          :user => user
  end
  
  def confirmation_email(user)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "Welcome To Workshop In Business Opportunities"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user, :host=> SITE_HOST_NAME
  end


#  def billing_email(user)
#    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
#    from          "Workshop In Business Opportunities <noreply@wibo.wickedstart.com>"
#    subject       "Account Activation Charge Successful"
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :user => user
#  end

  def message_posted_email(moderators, message)
    #    recipients    User.find(2, 47, 53, 54, 57, 69, 70, 71).map {|mod| "#{mod.first_name} #{mod.last_name} <#{mod.email}>"}
    recipients    moderators.map {|mod| "#{mod.first_name} #{mod.last_name} <#{mod.email}>"}
    from          FROM_EMAIL
    subject       "#{message.user.screen_name} has posted message #{( (message.title.length > 20) ? message.title.slice(0,17) + "..." : message.title )}"
    sent_on       Time.now
    content_type  "text/html"
    body          :message => message
  end

  def reply_to_message_email(sender, receiver, message, reply)
    recipients    "#{receiver.first_name} #{receiver.last_name} <#{receiver.email}>"
    from          FROM_EMAIL
    subject       "#{sender.screen_name} has replied to your message #{( (message.title.length > 20) ? message.title.slice(0,17) + "..." : message.title )}"
    sent_on       Time.now
    content_type  "text/html"
    body          :sender => sender, :receiver => receiver, :message => message, :reply => reply, :reply_url => SITE_URL_FOR_MAILS+message_comments_path(message)
  end

  def reply_to_inappropriate_email(inappropriate)
    recipients    "#{inappropriate.user.first_name} #{inappropriate.user.last_name} <#{inappropriate.user.email}>"
    from          FROM_EMAIL
    subject       "Reply to your request for Inappropriate Message #{inappropriate.appropriable.body.slice(0, 20)}"
    sent_on       Time.now
    content_type  "text/html"
    body          :receiver => inappropriate.user, :message_body => inappropriate.appropriable.body, :reply_body => inappropriate.answer
  end

  def alert_email(user,section)
    recipients    user.email
    from          FROM_EMAIL
    subject       "#{user.project.business_name} Due Date Approaching"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user, :section => section
  end

  def warning_email(user)
    recipients    user.email
    from          FROM_EMAIL
    subject       "Account Billing Unsuccessful"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user
  end

  def block_account_email(user)
    recipients    user.email
    from          FROM_EMAIL
    subject       "Account Cancellation"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user
  end

  def charge_successful_email(user)
    recipients    user.email
    from          FROM_EMAIL
    subject       "Wicked Start Invoice Transaction #{user.credential.transaction_id}"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user
  end

  def leave_account_email(user)
    recipients    user.email
    from          FROM_EMAIL
    subject       "Account Closing"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user
  end

  def check_in_email_third_day(user)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "You've identified your business model"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user
  end

  def check_in_email_fifth_day(user)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "You've identified your business model"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user
  end

  def submit_resource_email(resource)
    recipients    CONTACT_US_EMAIL
    bcc           CONTACT_US_BCC_EMAIL unless CONTACT_US_BCC_EMAIL.blank?
    from          resource[:email]
    subject       'Submit Resource Request'
    sent_on       Time.now
    content_type  "text/html"
    body          :resource => resource
  end

  def following_a_question_email(user, message)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "You're following [#{message.body}]"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user, :message => message
  end

  def comment_email(receiver, comment)
    recipients    "#{receiver.first_name} #{receiver.last_name} <#{receiver.email}>"
    from          FROM_EMAIL
    subject       "#{comment.user.name} has commented on your comment."
    sent_on       Time.now
    content_type  "text/html"
    body          :user => receiver, :message => comment
  end

  def edit_message_email_to_followers(user, message)
    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
    from          FROM_EMAIL
    subject       "#{message.user.name} has edited his/her post."
    sent_on       Time.now
    content_type  "text/html"
    body          :user => user, :message => message
  end

  def comment_on_message_email(receiver, comment, message)
    recipients    "#{receiver.first_name} #{receiver.last_name} <#{receiver.email}>"
    from          FROM_EMAIL
    subject       (receiver.id == message.user_id) ? "#{comment.user.name} has commented on your Question (#{truncate(message.body, 100)})." : "#{comment.user.name} also commented on #{message.user.name}'s Question (#{truncate(message.body, 100)})."
    sent_on       Time.now
    content_type  "text/html"
    body          :receiver => receiver, :commenter => comment.user, :comment => comment, :message => message
  end
  
  def email_after_step1_ended(receiver)
    recipients    "#{receiver.first_name} #{receiver.last_name} <#{receiver.email}>"
    from          FROM_EMAIL
    subject       "Congrats: You're ready to meet with a counselor/mentor"
    sent_on       Time.now
    content_type  "text/html"
    body          :user => receiver
  end
  
  def email_to_mentor(content)
    recipients    "#{content[:to]}"
    from          "#{content[:user].name} <#{content[:user].email}>"
    subject       "#{ content[:subject] }"
    sent_on       Time.now
    content_type  "text/html"
    body          :content => content
  end

#  def updating_a_question_email(user, message )
#    recipients    "#{user.first_name} #{user.last_name} <#{user.email}>"
#    from          "The Wicked Start Team <noreply@wickedstart.com>"
#    subject       "The question you are following has been changed. [#{message.body}]"
#    sent_on       Time.now
#    content_type  "text/html"
#    body          :user => user, :message => message
#  end
end

