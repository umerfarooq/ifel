class UserSessionsController < ApplicationController
  ssl_required  :new, :create
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  protect_from_forgery :except => [:new, :create]
  before_filter :set_new_design_theme, :only => [:new, :create]

  def new
    @new_login = true
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save  
      set_shared_cookie(@user_session.user)     
      return redirect_back_or_default(root_url)
    else
      @new_login = false
      return render :action => 'new'
    end
  end

  def destroy
    @user_session = UserSession.find
    clear_shared_cookie
    @user_session.destroy
    flash[:success] = ""
    flash[:notice] = ""
    flash[:error] = ""
    reset_session
    redirect_to root_url
  end
end

