class PasswordsController < ApplicationController
  ssl_required :change, :update
  before_filter :load_user_using_perishable_token, :only => [:change, :update]
  before_filter { |c| c.active_tab=nil }
  before_filter :require_no_user
  before_filter :set_new_design_theme

  def forget
    render
  end

  def create
    @login = params[:login]
    @email = params[:email]
    @user = User.find_by_login(@login) unless @login.blank?
    @user = @user ||= User.find_by_email(@email) unless @email.blank?

    if params[:login].blank? && params[:email].blank?
      #      @error = "Please enter username or email address."
      flash[:error] = "Please enter username or email address."
      #      render :action => 'forget'
    elsif !verify_recaptcha
      #      @error = "Wrong captcha, please re-enter."
      flash[:error] = "Wrong captcha, please re-enter."
      #      render :action => 'forget'
    elsif @user
      #      @user.deliver_password_reset_email!
      @user.send_later(:deliver_password_reset_email!)
      flash[:notice] = "Please check your email for password reset request."
      flash[:error] = nil
      return render :action => 'confirmation'
    else
      #      @error = "User not found for provided username or email address."
      flash[:error] = "User not found for provided username or email address."
      #      render :action => 'forget'
    end
    render :action => 'forget'
  end

  def change
    #    logger.debug "__ __CONTROLLER:PASSWORDS__ __ACTION:CHANGE__ __"
    #    logger.debug "__ __PARAMS:{#{params.inspect}}__ __"
    #    logger.debug "__ __USER:{#{@user.inspect}}__ __"
    #    @perishable_user_id = params[:id]
    #    logger.debug "__ __USER:{#{@perishable_user_id}}__ __"
    render
  end
  
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.password_modified_date = Time.now
    if @user.save
      forum_user = ForumAccount.find_by_username(@user.login)
      if forum_user
        forum_user.encrypt_and_save_new_password(params[:user][:password])
      end
      set_shared_cookie @user
      flash[:notice] = "Password successfuly updated."
      redirect_to root_url
    else
      render :action => 'change'
    end
  end
  
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id], 1.day)
    unless @user
      logger.debug "__ __CONTROLLER:PASSWORDS__ __ACTION:CHANGE__ __MESSAGE:USER_NOT_FOUND__ __"
      flash[:notice] = "We're sorry, but we could not locate your account."
      return redirect_to root_url
    end
  end
end

