class DocumentCategoriesController < ApplicationController
  before_filter :require_admin
  before_filter { |c| c.active_tab = :content_tab }

  def new
    @document_category = DocumentCategory.new
  end

  def create
    @message_main = MarketingTextMessage.find_by_page_and_location("my_files", "main")
    @document_categories = DocumentCategory.all

    @document_category = DocumentCategory.new(:title => params[:document_category][:title])
    @document_category.state = State.find_by_name('inactivate')
    if @document_category.save
      flash[:notice] = "Document Category successfully added."
      redirect_to list_document_categories_url
    else
      render :action => 'list'
    end
  end

  def edit
    @document_category = DocumentCategory.find params[:id]
  end

  def update
    document_category = DocumentCategory.find params[:id]
    document_category.title = params[:document_category][:title]
#    document_category.state = State.find_by_name('inactivate')
    if document_category.save
      flash[:notice] = "Document Category successfully updated"
    else
      flash[:notice] = "Document Category could not be updated"
    end
    redirect_to list_document_categories_url
  end

  def list
    @message_main = MarketingTextMessage.find_by_page_and_location("my_files", "main")
    @message_no_doc = MarketingTextMessage.find_by_page_and_location("my_files", "no_document")
    @document_category = DocumentCategory.new
    @document_categories = DocumentCategory.all
  end

  def publish
    document_category = DocumentCategory.find params[:id]
    if document_category.state.is_activated?
      document_category.state = State.find_by_name('publish')
      document_category.save
      flash[:notice] = "Document Category successfully published"
    else
      flash[:notice] = "Document Category is not publishable"
    end
    return redirect_to :back
  end

  def activate
    document_category = DocumentCategory.find params[:id]
    if document_category.state.is_inactivated?
      document_category.state = State.find_by_name('activate')
      document_category.save
      flash[:notice] = "Document Category successfully activated"
    else
      flash[:notice] = "Document Category is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    document_category = DocumentCategory.find params[:id]
    if document_category.state.is_inactivated?
      flash[:notice] = "Document Category is not inactivatable"
    else
      document_category.state = State.find_by_name('inactivate')
      document_category.save
      flash[:notice] = "Document Category successfully inactivated"
    end
    return redirect_to :back
  end

end
