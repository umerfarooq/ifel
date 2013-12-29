class ResourceCategoriesController < ApplicationController
  uses_tiny_mce :only => [:edit_content_message,:edit_resource_message, :summary]
  before_filter :require_admin, :except => [:index, :show]
  before_filter :require_user,  :only   => [:index, :show]
  before_filter :require_payment,  :only   => [:index, :show]
  before_filter { |c| c.active_tab=:resource_tab }
  before_filter(:only => [:edit_resource_message, :update_resource_message]) { |c| c.active_tab=:checklist }


  def new
    @resource_category = ResourceCategory.new
  end

  def create
    @resources = Resource.all
    @resource_categories = ResourceCategory.all
    @resource_category = ResourceCategory.new(:title => params[:resource_category][:title])
    @resource_category.state = State.find_by_name('inactivate')
    if @resource_category.save
      flash[:notice] = "Resource Type successfully added."
    else
      flash[:notice] = "Resource Type could not be added"
    end
    redirect_to list_resource_categories_url
  end

  def show
    @category, bln_success = ResourceCategory.get_category(params[:id])
    #    return render :text => @category.inspect
    if(bln_success == 1)
      return render :partial => "resource_categories"
    else
      #show error message
    end
  end

  def index
    @resources_message = MarketingTextMessage.find(:all,:conditions=>{:title=>"Resources Page General Message",:state_id => 1})
    @categories, bln_success = ResourceCategory.get_categories
    if(bln_success == 1)
      #      return render :text => "hello world"
    else
      #show error message
      #      return render :text => "what is"
    end
  end

  def destroy
    resource_category = ResourceCategory.find params[:id]
    if resource_category.destroy
      flash[:success] = "Resource Type is deleted."
    else
      flash[:notice] = "Resource Type can't be deleted."
    end
    return redirect_to :back
  end

  def update
    resource_category = ResourceCategory.find params[:id]
    resource_category.update_attribute("title", params[:resource_category][:title])
    #    resource_category.state = State.find_by_name('inactivate')
    if resource_category.save
      flash[:notice] = "Resource Type successfully updated"
    else
      flash[:notice] = "Resource Type could not be updated"
    end
    redirect_to list_resource_categories_url
  end


  def list
    @resource_category = ResourceCategory.new
    @resource_categories = ResourceCategory.all
    
#    
    
    @marketing_multimedia_message = MarketingMultimediaMessage.find_all_by_page("resources")
#    @main_content_message = MarketingTextMessage.find_by_page_and_location('resources','main_content')
    
  end

  def edit_content_message
    @marketing_text_message = MarketingTextMessage.find params[:id]
  end

  def edit_resource_message
    @resource_text_message = ResourceTextMessage.find params[:id]
  end
  
  def update_resource_message
    @resource_text_message = ResourceTextMessage.find params[:id]
    if @resource_text_message.update_attributes(params[:resource_text_message])
      flash[:notice] = "Resource Section Template Description updated successfully."
      redirect_to '/admins/action_items'
    else
      render :action => 'edit_resource_message'
    end
  end

  def update_content_message
    @marketing_text_message = MarketingTextMessage.find params[:id]
    if @marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:notice] = "Resource Content Message updated successfully."
      redirect_to list_resource_categories_path
    else
      render :action => 'edit_content_message'
    end
  end

  def summary
    @marketing_multimedia_message = MarketingMultimediaMessage.find params[:id]
    #@back = params[:back] || request.env["HTTP_REFERER"]
    #  redirect_to list_resource_categories_url
  end

  def update_summary
    @marketing_multimedia_message = MarketingMultimediaMessage.find params[:id]
    if @marketing_multimedia_message.update_attributes(params[:marketing_multimedia_message])
      flash[:notice] = "Message updated successfully."
      redirect_to list_resource_categories_path
    else
      render :action => 'summary'
    end
  end
  

  def publish
    resource_category = ResourceCategory.find params[:id]
    if resource_category.state.is_activated?
      resource_category.state = State.find_by_name('publish')
      resource_category.save
      flash[:notice] = "Resource Type successfully published"
    else
      flash[:notice] = "Resource Type is not publishable"
    end
    redirect_to list_resource_categories_url
  end

  def activate
    resource_category = ResourceCategory.find params[:id]
    if resource_category.state.is_inactivated?
      resource_category.state = State.find_by_name('activate')
      resource_category.save
      flash[:notice] = "Resource Type successfully activated"
    else
      flash[:notice] = "Resource Type is not activatable"
    end
    redirect_to list_resource_categories_url
  end

  def inactivate
    resource_category = ResourceCategory.find params[:id]
    if resource_category.state.is_inactivated?
      flash[:notice] = "Resource Type is not inactivatable"
    else
      resource_category.state = State.find_by_name('inactivate')
      resource_category.save
      flash[:notice] = "Resource Type successfully inactivated"
    end
    redirect_to list_resource_categories_url
  end
end
