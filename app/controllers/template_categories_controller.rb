class TemplateCategoriesController < ApplicationController
  before_filter :require_admin
  before_filter { |c| c.active_tab = :content_tab }

  def new
    @template_category = TemplateCategory.new
  end

  def create
    @template_categories = TemplateCategory.all
    @template_documents = TemplateDocument.all
    @template_category = TemplateCategory.new(:title => params[:template_category][:title])
    @template_category.state = State.find_by_name('inactivate')
    if @template_category.save
      flash[:notice] = "Template Category successfully added."
      redirect_to list_template_categories_url
    else
      render :action => 'list'
    end
  end

  def edit
    @template_category = TemplateCategory.find params[:id]
  end

  def update
    template_category = TemplateCategory.find params[:id]
    template_category.title = params[:template_category][:title]
#    template_category.state = State.find_by_name('inactivate')
    if template_category.save
      flash[:notice] = "Template Category successfully updated"
    else
      flash[:notice] = "Template Category could not be updated"
    end
    redirect_to list_template_categories_url
  end

  def list
    @template_category = TemplateCategory.new
    @template_categories = TemplateCategory.all
    if params[:c]
      @template_documents = TemplateDocument.title_wise(params[:d])
    else
      @template_documents = TemplateDocument.title_wise('asc')
    end  
  end

  def publish
    template_category = TemplateCategory.find params[:id]
    if template_category.state.is_activated?
      template_category.state = State.find_by_name('publish')
      template_category.save
      flash[:notice] = "Template Category successfully published"
    else
      flash[:notice] = "Template Category is not publishable"
    end
    redirect_to list_template_categories_url
  end

  def activate
    template_category = TemplateCategory.find params[:id]
    if template_category.state.is_inactivated?
      template_category.state = State.find_by_name('activate')
      template_category.save
      flash[:notice] = "Template Category successfully activated"
    else
      flash[:notice] = "Template Category is not activatable"
    end
    redirect_to list_template_categories_url
  end

  def inactivate
    template_category = TemplateCategory.find params[:id]
    if template_category.state.is_inactivated?
      flash[:notice] = "Template Category is not inactivatable"
    else
      template_category.state = State.find_by_name('inactivate')
      template_category.save
      flash[:notice] = "Template Category successfully inactivated"
    end
    redirect_to list_template_categories_url
  end

end
