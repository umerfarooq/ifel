class FaqCategoriesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter { |c| c.active_tab=:content_tab }
  before_filter :require_user

  def index
    @faqs = Faq.all
    @faq_categories = FaqCategory.all 
  end
  
  def new
    @faq_category = FaqCategory.new
  end

  def create
    @faq_category = FaqCategory.new(params[:faq_category])
    @faq_category.state = State.find_by_name('inactivate')
    if @faq_category.save
      flash[:notice] = "FAQ Category successfully added."
      redirect_to faq_categories_url
    else
      render :action => 'new'
    end
  end

  def edit
    @faq_category = FaqCategory.find params[:id]
  end

  def update
    faq_category = FaqCategory.find params[:id]
    if faq_category.update_attributes(:title => params[:faq_category][:title])
      flash[:notice] = "FAQ Category successfully updated"
      redirect_to faq_categories_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @faq_category = FaqCategory.find params[:id]
    if @faq_category.destroy
      flash[:success] = "FAQ Category is deleted."
    else
      flash[:notice] = "FAQ Category can't be deleted."
    end
    return redirect_to :back
  end
  
  def publish
    faq_category = FaqCategory.find params[:id]
    if faq_category.state == State.find_by_name('activate')
      faq_category.state = State.find_by_name('publish')
      faq_category.save
      flash[:notice] = "FAQ Category successfully published"
    else
      flash[:notice] = "FAQ Category is not publishable"
    end
    redirect_to faq_categories_url
  end

  def activate
    faq_category = FaqCategory.find params[:id]
    if faq_category.state == State.find_by_name('inactivate')
      faq_category.state = State.find_by_name('activate')
      faq_category.save
      flash[:notice] = "FAQ Category successfully activated"
    else
      flash[:notice] = "FAQ Category is not activatable"
    end
    redirect_to faq_categories_url
  end

  def inactivate
    faq_category = FaqCategory.find params[:id]
    if faq_category.state == State.find_by_name('inactivate')
      flash[:notice] = "FAQ Category is not inactivatable"
    else
      faq_category.state = State.find_by_name('inactivate')
      faq_category.save
      flash[:notice] = "FAQ Category successfully inactivated"
    end
    redirect_to faq_categories_url
  end

end
