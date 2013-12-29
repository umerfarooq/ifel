class InappropriatesController < ApplicationController
  def index
  end

  def edit
    @inappropriate = Inappropriate.find params[:id]
  end

  def update
    @inappropriate = Inappropriate.find params[:id]
    if @inappropriate.update_attributes(params[:inappropriate])
      @inappropriate.deliver_reply_to_inappropriate_email
      flash[:notice] = "Inappropriate updated successfully."
      redirect_to list_message_categories_url
    else
      render :action => 'edit'
    end
  end

end
