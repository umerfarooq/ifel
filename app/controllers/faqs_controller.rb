class FaqsController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter { |c| c.active_tab=:content_tab }
  
  def index
    @faq_categories = FaqCategory.published
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(params[:faq])
    @faq.faq_category = FaqCategory.find(params[:faq][:faq_category_id]) if params[:faq][:faq_category_id].present?
    if @faq.save
      flash[:notice] = "FAQ successfully added."
      redirect_to faq_categories_url
    else
      render :action => 'new'
    end
  end

  def edit
    @faq = Faq.find params[:id]
  end

  def update
    @faq = Faq.find params[:id]
    @faq.faq_category = FaqCategory.find(params[:faq][:faq_category_id]) if params[:faq][:faq_category_id].present?
    if @faq.update_attributes(params[:faq])
      flash[:notice] = "FAQ updated successfully."
      redirect_to faq_categories_url
    else
      render :action => 'edit'
    end
  end

  #  def destroy
  #    @faq = Faq.find params[:id]
  #    # @biography.destroy
  #    @faq.status = "destroyed"
  #    if @faq.save
  #      flash[:notice] = 'Faq marked destroyed.'
  #    else
  #      flash[:notice] = 'Faq cannot be marked destroyed.'
  #    end
  #    redirect_to(root_path)
  #  end
  #
  #  def change_state
  #    @faq = Faq.find params[:id]
  #    @faq.state = State.find_by_title(params[:state])
  #    if @faq.save
  #    else
  #    end
  #    redirect_to '/admins/faqs_tab'
  #  end

  def publish
    faq = Faq.find params[:id]
    if faq.state == State.find_by_name('activate')
      faq.state = State.find_by_name('publish')
      faq.save
      flash[:notice] = "FAQ successfully published"
    else
      flash[:notice] = "FAQ is not publishable"
    end
    redirect_to faq_categories_url
  end

  def activate
    faq = Faq.find params[:id]
    if faq.state == State.find_by_name('inactivate')
      faq.state = State.find_by_name('activate')
      faq.save
      flash[:notice] = "FAQ successfully activated"
    else
      flash[:notice] = "FAQ is not activatable"
    end
    redirect_to faq_categories_url
  end

  def inactivate
    faq = Faq.find params[:id]
    if faq.state == State.find_by_name('inactivate')
      flash[:notice] = "FAQ is not inactivatable"
    else
      faq.state = State.find_by_name('inactivate')
      faq.save
      flash[:notice] = "FAQ successfully inactivated"
    end
    redirect_to faq_categories_url
  end

end
