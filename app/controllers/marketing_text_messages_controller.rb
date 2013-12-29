class MarketingTextMessagesController < ApplicationController
  
  uses_tiny_mce :only => [:edit,:update]
  


  
  def new
    @marketing_text_message = MarketingTextMessage.new
  end

  def create
#    return render :text=>params.inspect
    @marketing_text_message = MarketingTextMessage.new(params[:marketing_text_message])
    if @marketing_text_message.save
      flash[:notice] = "Marketing Message successfully added."
      redirect_to :back
    else
      render :action => 'new'
    end
  end

  def destroy
    @marketing_text_message = MarketingTextMessage.find params[:id]
    if @marketing_text_message.destroy
      flash[:success] = "Message is deleted."
    else
      flash[:notice] = "Message can't be deleted."
    end
    return redirect_to :back
  end

  def edit
    @marketing_text_message = MarketingTextMessage.find params[:id]
    @back = params[:back] || request.env["HTTP_REFERER"]
  end

  def update
    @marketing_text_message = MarketingTextMessage.find params[:id]
#    if @marketing_text_message.update_attributes(:title => params[:marketing_text_message][:title], :content => params[:marketing_text_message][:content])
     if @marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:success] = "Message updated successfully."
      redirect_to params[:back] || :back
#      redirect_to :back
    else
      render :action => 'edit'
    end
  end

  def index
  end

  def show
  end

  def edit_post_message_content
    @marketing_text_message = MarketingTextMessage.find params[:id]
  end

  def update_post_message_content
        @marketing_text_message = MarketingTextMessage.find params[:id]
#    if @marketing_text_message.update_attributes(:title => params[:marketing_text_message][:title], :content => params[:marketing_text_message][:content])
     if @marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:success] = "Message updated successfully."
      redirect_to params[:back] || :back
#      redirect_to :back
    else
      render :action => 'edit_post_message_content'
    end
  end

end
