class ConfigurationsController < ApplicationController
  before_filter :require_admin
  uses_tiny_mce :only => [:accounts]
  before_filter(:only => [:accounts, :designs]) { |c| c.active_tab=:account_tab }
#  before_filter(:only => [:designs]) { |c| c.active_tab=:design_tab }
  before_filter :load_configurations
  
  
  def edit
    @back = params[:back] || request.env["HTTP_REFERER"]
  end
  
  def update
    if @configurations.update_attributes(params[:configuration])
      flash[:success] = "Information updated successfully."
      redirect_to params[:back] || :back
    else
      render :action => 'edit'
    end
  end
  
  def accounts
    
  end
  
  def designs
    
  end
  
  private
  def load_configurations
    @configurations = Configuration.first
  end
  
end
