# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found unless Rails.env.development?
  rescue_from CanCan::AccessDenied, :with => :cannot_cancan unless Rails.env.development?

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation, :card_number, :card_verification

  # helper methods for controllers and views
  #  helper_method :current_user_session, :current_user, :current_user_is_admin?, :active_tab, :enable_light_box, :disable_light_box
  helper_method :current_user_session, :current_user, :current_user_is_admin?, :active_tab, :configurations
  before_filter :set_time_zone#, :require_http_basic_auth
  # TODO [11/2/10 2:35 AM] => TEST_AND_REMOVE_CODE (:enable_light_box, :disable_light_box)
  #  def enable_light_box
  #    @light_box = true
  #  end
  #
  #  def disable_light_box
  #    @light_box = false
  #  end
  #
  
  
  def require_http_basic_auth
    if APP_CONFIG['perform_authentication']
      authenticate_or_request_with_http_basic do |login, password|
        login==APP_CONFIG['username'] and password == APP_CONFIG['password']
      end
    end
  end

  def set_new_design_theme
    @new_design_theme = true
  end

  def active_tab=(name)
    @active_tab = name
  end

  def active_tab
    @active_tab
  end
  
  def configurations
    @configurations = Configuration.first
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def current_user_is_admin?
    current_user && @current_user.is_admin?
  end

  def login_required
    require_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "Your session has been expired, please log in again to access your account"
      #redirect_to new_user_session_url
      redirect_to login_url
      return false
    end
  end
  
  def require_to_be_logged_in
    unless current_user
      store_location
      flash[:notice] = "You need to be logged in, to access this page"
      redirect_to login_url
      return false
    end
  end
  
  def redirect_nyu_user
    flash[:notice] = "Page not found"
    redirect_to public_home_url
    return false
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      #redirect_to users_url
      redirect_to root_url
      return false
    end
  end

  def require_admin
    unless current_user && current_user.is_admin?
      store_location
      flash[:notice] = "Page not found or Access Denied."
      #redirect_to new_user_session_url
      redirect_to login_url
      return false
    end
  end

  def require_no_admin
    if current_user && current_user.is_admin?
      store_location
      flash[:notice] = "Admin cannot access this page"
      #redirect_to users_url
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def record_not_found(exception)
    logger.info exception.message
    #    render home_path('404'), :status => 404
    #    render home_url('four_o_four'), :status => 404
    #    render :controller => 'home', :action => 'show', :page => 'four_o_four', :status => 404
    #    render '/home/four_o_four', :status => 404, :layout => 'application'
    render '/home/four_o_four', :status => 404, :layout => true
    #    render '/home/four_o_four', :status => 404
  end

  def require_payment
    if current_user
      if current_user.is_blocked
        store_location
        user_session = UserSession.find
        user_session.destroy
        flash[:error] = "Your WIBO account is closed. Please contact customer support to have it re-opened."
        redirect_to public_home_path
      end
    end
  end

  def requesting_host
    request.protocol+request.host_with_port
  end
  
  
  #----------punBB Start-------------#
  
  # RAILS_ROOT/app/controllers/application_controller.rb
  def set_shared_cookie(user)
    #    return true unless Rails.env.production?
    require 'base64'
    expires = Time.now.to_i + 1209600

    begin
      # this sets the punbb cookie
      # it should be called on login from main site to allow unified login
      forumconfig = get_forum_config_data() # private method at bottom
      forumuser = ForumAccount.find_by_username( user.login )
      forum_hash = Digest::SHA1.hexdigest( forumuser.salt + Digest::SHA1.hexdigest( expires.to_s ) )
      cookie_value = "#{forumuser.id}|#{forumuser.password}|#{expires.to_s}|"
      cookie_value << Digest::SHA1.hexdigest( "#{forumuser.salt}#{forumuser.password}#{forum_hash}" )
      cookies[forumconfig[:cookie_name]] = {
        :value => Base64.encode64( cookie_value ),
        :expires => 14.days.from_now
      }
    rescue => e
      Rails.logger.warn "Problem setting punBB cookie #{e.message}"
    end
    
  end

  def clear_shared_cookie
    #    return true unless Rails.env.production?
    begin
      # should be called on logout from main site
      forumconfig = get_forum_config_data() # private method at bottom
      cookies[forumconfig[:cookie_name]] = nil
    rescue => e
      Rails.logger.warn "Problem clearing punBB cookie #{e.message}"
    end
    
  end

  private
  # Uses regex to parse the php punbb config file
  def get_forum_config_data
    config_hash = Hash.new
    c = File.read( File.join( RAILS_ROOT, 'public' , 'forum', 'config.php' ) )
    c.scan(/\$(\w*)\s*=\s*['&quot;](.*)['&quot;];/).each do |pair|
      config_hash[pair[0].to_sym] = pair[1]
    end
    config_hash
  end

  #----------punBB End---------------#
  
  def cannot_cancan(exception)
    if current_user
      logger.info exception.message
      flash.now[:error] = "You are not authorized to access this page."
      render '/home/four_o_four', :status => 404, :layout => true
    else
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
  end
  
  def set_time_zone       
    Time.zone = 'Eastern Time (US & Canada)'
  end

end

