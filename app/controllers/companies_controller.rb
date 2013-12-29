class CompaniesController < ApplicationController
  before_filter :require_user,  :only => [:index,:update]
  before_filter :set_new_design_theme, :only => [:index,:update]
  before_filter { |c| c.active_tab=:startup_workspace }
  before_filter :load_content
  ssl_required  :index,:update,:update
  ssl_allowed   :upload_logo,:upload_mark
  
  def index
    @user = @current_user
    if(!@user.company)
      @company = Company.new
      @company.user = @user
      @company.save_with_validation(false)
    else
      @company = @user.company
    end
  end
  
  def update
    @user = @current_user
    @company = @user.company
    params[:company][:start_date]=params[:user][:startup_process_start_date];
    params[:company][:launch_date]=params[:user][:startup_process_end_date];
    params[:company][:name] = params[:user][:business_idea]
    if(@company.update_attributes(params[:company]) && @user.update_attributes(params[:user]))
      redirect_back_or_default("/company_profile")
    else
      return render :action => 'index'
    end
  end
  
  def upload_logo
    company = Company.find(params[:id].to_i)
    if company.update_attribute(:logo, params[:userfile])
      return render :text => {:success => true, :path => company.logo.url(:profile_view).as_json}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => company.errors.as_json}.to_json
    end
  end
  
  def upload_mark
    company = Company.find(params[:id].to_i)
    if company.update_attribute(:logo_mark, params[:userfile])
      return render :text => {:success => true, :path => company.logo_mark.url(:profile_view).as_json}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => company.errors.as_json}.to_json
    end
  end

  def update_company_content
    if MarketingTextMessage.find(params[:id].to_i).update_attributes(params[:marketing_text_message])
      flash[:notice] = "Company Profile updated successfully."
    end
    redirect_to params[:back] || :back
  end

  private
  def load_content
    @company_content = MarketingTextMessage.get_company_contents current_user
  end
  
end
