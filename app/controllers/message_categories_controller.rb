class MessageCategoriesController < ApplicationController
  before_filter :require_admin
  before_filter { |c| c.active_tab = :content_tab }

  def new
    @message_category = MessageCategory.new
  end

  def create
    @message_main = MarketingTextMessage.find_by_page_and_location("community", "main")
    @message_categories = MessageCategory.all
    @message_category = MessageCategory.new(:title => params[:message_category][:title])
    @message_category.state = State.find_by_name('inactivate')
    if @message_category.save
      flash[:notice] = "Message Category successfully added."
      redirect_to list_message_categories_url
    else
      render :action => 'list'
    end
  end

  def edit
    @message_category = MessageCategory.find params[:id]
  end

  def update
    message_category = MessageCategory.find params[:id]
    message_category.title = params[:message_category][:title]
#    message_category.state = State.find_by_name('inactivate')
    if message_category.save
      flash[:notice] = "Message Category successfully updated"
    else
      flash[:notice] = "Message Category could not be updated"
    end
    redirect_to list_message_categories_url
  end

  def list
    @message_main = MarketingTextMessage.find_by_page_and_location("community", "main")
    @message_no_msg = MarketingTextMessage.find_by_page_and_location("community", "no_message")
    @message_category = MessageCategory.new
    @message_categories = MessageCategory.all
    @inappropriate_requests = Inappropriate.find_all_by_is_answered false
  end

  def publish
    message_category = MessageCategory.find params[:id]
    if message_category.state.is_activated?
      message_category.state = State.find_by_name('publish')
      message_category.save
      flash[:notice] = "Message Category successfully published"
    else
      flash[:notice] = "Message Category is not publishable"
    end
    return redirect_to :back
  end

  def activate
    message_category = MessageCategory.find params[:id]
    if message_category.state.is_inactivated?
      message_category.state = State.find_by_name('activate')
      message_category.save
      flash[:notice] = "Message Category successfully activated"
    else
      flash[:notice] = "Message Category is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    message_category = MessageCategory.find params[:id]
    if message_category.state.is_inactivated?
      flash[:notice] = "Message Category is not inactivatable"
    elsif message_category.messages.blank?
      message_category.state = State.find_by_name('inactivate')
      message_category.save
      flash[:notice] = "Message Category successfully inactivated"
    else
      flash[:notice] = "Message Category has messages in it so cannot be inactivated"
    end
    return redirect_to :back
  end

end
