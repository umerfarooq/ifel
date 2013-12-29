class ContactUsController < ApplicationController
  before_filter :redirect_nyu_user
  before_filter { |c| c.active_tab=:about_us }
  before_filter :set_new_design_theme

  def show
    @url_for_back = request.env["HTTP_REFERER"] || root_url
    @contact_us = ContactUs::Contact.new.becomes(ContactUs)
  end

  def create
    @contact_us = ContactUs::Contact.new(params[:contact_us]).becomes(ContactUs)
    if @contact_us.save
      # @contact_us.deliver_contact_us_email
      @contact_us.send_later(:deliver_contact_us_email)
      flash[:success] = "Thank you for contacting Wicked Start. Someone from our team will respond to you shortly."
#      redirect_to :action => 'reply', :url_for_back => (params[:url_for_back] || root_url)
      @contact_us = ContactUs::Contact.new.becomes(ContactUs)
    end
    render :action => 'show'
  end

  def reply
    @url_for_back = params[:url_for_back] || root_url
    @from = params[:from]
  end

  def new
    logger.debug "__ __CONTROLLER:CONTACT_US__ __"
    logger.debug "__ __ACTION:NEW__ __"
    logger.debug "__ __params:#{params.inspect}__ __"
    @topic = params[:topic]
    @url_for_back = params[:url_for_back] || request.env["HTTP_REFERER"]
    logger.debug "__ __@url_for_back:#{@url_for_back}__ __"
    if @topic == 'news_letter'
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "news_letter")
      @contact_us = ContactUs.new(:subject => "Sign up for Wicked Start's newsletter", :message => "Please sign me up to receive Wicked Start's newsletter.")
    elsif @topic == 'registration'
      return redirect_to signup_path  # TODO [8/13/10 3:58 PM] => REMOVE IT AFTER ONE WEEK, MONDAY August 22, 2010
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "registration")
      @contact_us = ContactUs.new(:subject => "Registration notification", :message => "Please notify me when Wicked Start's platform has gone live.")
    elsif @topic == 'page_not_found'
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "page_not_found")
      @contact_us = ContactUs.new(:subject => "Page Not Found", :message => "I could not get the page requested while accessing: "+params[:url])
    else
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "main")
      @contact_us = ContactUs.new
    end
  end

  def create_bak
    logger.debug "__ __CONTROLLER:CONTACT_US__ __"
    logger.debug "__ __ACTION:CREATE__ __"
    logger.debug "__ __params:#{params.inspect}__ __"
    @contact_us = ContactUs.new(params[:contact_us])
    if params[:topic] == 'news_letter'
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "news_letter")
    elsif params[:topic] == 'registration'
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "registration")
    else
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "main")
    end
    #    @url_for_back = params[:url_for_back]
    if @contact_us.save
      @contact_us.deliver_contact_us_email
      redirect_to :action => 'thanks', :topic => params[:topic], :url_for_back => params[:url_for_back]
    else
      render :action => 'new'
    end
  end

  def thanks
    @url_for_back = params[:url_for_back]
    if params[:topic] == 'news_letter'
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "news_letter_response")
    elsif params[:topic] == 'registration'
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "registration_response")
    else
      @message_contact_us = MarketingTextMessage.find_by_page_and_location("contact_us", "contact_us_response")
    end
  end

  def subscribe_for_news_letters
    success_message = "Thank you for signing up for the Wicked Start Tips & Inspiration newsletter."
    error_message = "Sorry, could not sign up for the Wicked Start Tips & Inspiration newsletter."
    params[:contact_us][:first_name] = params[:contact_us][:email]
    params[:contact_us][:last_name] = params[:contact_us][:email]
    params[:contact_us][:message] = TEXT_FOR_NEWSLETTER_SUBSCRIPTION    
    @contact_us = ContactUs::Newsletter.new(params[:contact_us]).becomes(ContactUs)
    @contact_us.subject = Subject.newsletter_subjects.first
        
    if @contact_us.save
      @contact_us.send_later(:deliver_contact_us_email)
      @contact_us.send_later(:deliver_newsletter_subscription_email)
      if params[:contact_us][:request_from] == 'blog'
        $success_for_blog = success_message
      else
        flash[:success] = success_message
      end
      redirect_to((params[:contact_us][:request_from] == 'signup') ? '/signup' : :back)
    else
      if params[:contact_us][:request_from] == 'blog'
        $error_for_blog = error_message
      else
        flash[:error] = error_message
      end
      redirect_to((params[:contact_us][:request_from] == 'signup') ? '/signup' : :back)
    end
  end

end
