class ResourcesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update,:edit_service]
  before_filter :require_to_be_logged_in
  before_filter :set_new_design_theme, :only => [:index]
  # before_filter :require_admin, :except => [:index, :resource_library, :service_provider, :resource]
  before_filter { |c| c.active_tab = :resource_tab }
  before_filter :load_content, :only => [:index ]

  def index
  end

  def new
    @resource = Resource.new
  end
  
  def create    
    @resource = Resource.new(params[:resource])
    @resource.resource_category = ResourceCategory.find params[:resource][:resource_category_id] rescue nil
    @resource.state = State.find_by_name('inactivate')
    unless params[:resource][:pricing].blank?
      params[:resource][:pricing].each do |pricing|
        @resource.pricings << Pricing.find_by_id(pricing.to_i)
      end
    end
    @resource.tag_list.add(params[:tag_list])
    if @resource.save
      flash[:notice] = "Resource successfully added"
      redirect_to list_resources_url
    else
      render :action => 'new'
    end
  end

  def edit
    @resource = Resource.find params[:id]
  end

  def edit_service
    @resource = Resource.find params[:id]
  end

  def update
    @resource = Resource.find params[:id]
    #return render :text => @resource.pricings
    @resource.resource_category = ResourceCategory.find params[:resource][:resource_category_id]
    unless params[:resource][:pricing].blank?
      @resource.resource_pricings.destroy_all
      params[:resource][:pricing].each do |pricing|
        @resource.pricings << Pricing.find_by_id(pricing.to_i)
      end
    end
    @resource.tag_list = params[:tag_list]
    if @resource.update_attributes(params[:resource])
      flash[:notice] = "Resource successfully updated."
      redirect_to list_resources_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @resource = Resource.find params[:id]
    if @resource.destroy
      flash[:success] = "Resource is deleted."
    else
      flash[:notice] = "Resource can't be deleted."
    end
    return redirect_to :back
  end
  
  def load_all_tags
    tags = Tagging.tags_associated_to_resources
    return render :partial => 'tags_list', :locals => { :tags => tags }
  end
  
  def load_tag_content
    tag = Tag.find_by_id(params[:tag_id].to_i)
    resources = tag.associated_resources
    return render :partial => '/resources/tag_resources', :locals => {:tag => tag, :resources => resources}
  end
  
  def load_more_resources
    category = ResourceCategory.find(params[:category_id].to_i)
    resources = category.resources.published.sorted.only((params[:resources_count].to_i+5))
    return render :partial => '/resources/resources_list', :locals => {:resources=>resources}
  end
  
  def title
    @main_content_message = MarketingTextMessage.find_by_page_and_location('resources','main_content')
  end
  
  def list
    if params[:c]
      case params[:c]
      when 'title'
        @resources = (ResourceCategory.service_provider.blank?) ? Resource.title_wise(params[:d]) : Resource.resource_library_type(params[:d])
        @services = Resource.service_provider_type('asc') if ResourceCategory.service_provider
      when 'company_name'
        @resources = (ResourceCategory.service_provider.blank?) ? Resource.title_wise('asc') : Resource.resource_library_type('asc')
        @services = Resource.service_provider_type(params[:d]) if ResourceCategory.service_provider
      end      
    else
      @resources = (ResourceCategory.service_provider.blank?) ? Resource.title_wise('asc') : Resource.resource_library_type('asc') 
      @services = Resource.service_provider_type('asc') if ResourceCategory.service_provider
    end
  end
  
  def edit_content_message
    @marketing_text_message = MarketingTextMessage.find params[:id]
  end
  
  def update_content_message
    @marketing_text_message = MarketingTextMessage.find params[:id]
    if @marketing_text_message.update_attributes(params[:marketing_text_message])
      flash[:notice] = "Resource Content Message updated successfully."
      redirect_to title_resources_path
    else
      render :action => 'edit_content_message'
    end
  end
   
  #----------Deprecated-----------#
  # Deprecated in favor of new revamps
  # on 14th December, 2011. Now, Resources
  # would be listing all Resources and 
  # Service Providers al-together
  
  def resource_library
    #   top 10 types trending,only for resources
    #    @top_ten_categories = ResourceCategory.published.top_trending_types_for_resource_library
    #   top 10 tags trending for resources(resource + service provider)
    #    @top_ten_tags = ResourceCategory.top_tags_for_resource_library
    #   all tags for resources(resource + service provider)
    @all_tags = ResourceCategory.all_tags({:limit => 1000, :offset => 0 })
    @section_templates = SectionTemplate.published.sequence_wise
    @resource_library = MarketingMultimediaMessage.find_by_page("Resource Library")
    #@total_count = @resource_categories_count.sum(&:resource_count)
  end

  def load_resource_section_content
    section_template = SectionTemplate.find_by_id(params[:id])
    resource_ids = ''
    if section_template.id
      resource_ids = SectionTemplate.resource_ids(section_template.id)
    end
    #    @top_categories = ResourceCategory.published.all_categories_for_section_in_resource_library({:resources=>resource_ids,:section_template_id => section_template.id, :limit => 2})
    #    @top_ten_categories = ResourceCategory.published.top_trending_types_for_resource_library({:resources=>resource_ids,:section_template_id => section_template.id})
    #    @top_ten_tags = ResourceCategory.top_tags_for_resource_library({:resources=>resource_ids,:section_template_id => section_template.id})
    @all_tags = ResourceCategory.all_tags({:resources=>resource_ids,:section_template_id => section_template.id, :limit => 1000, :offset => 0})
    #    @categories_count = @top_categories.count()
    return render :partial => '/resources/middle', :locals => {:top_categories => @top_categories,:top_ten_categories => @top_ten_categories, :is_section_selected => true, :section_template => section_template.to_a, :categories_count => @categories_count, :top_ten_tags => @top_ten_tags, :all_tags => @all_tags, :is_resource_library => true, :is_default_page => false}
  end

  def service_provider
    @section_templates = SectionTemplate.published.sequence_wise
    @service_provider = MarketingMultimediaMessage.find_by_page("Service Provider")
    #    currently not in scope
    @top_categories = ResourceCategory.published.find_by_title("Service Provider")
    #    @top_ten_categories = ResourceCategory.published.top_trending_service_provider
    #    -------
    #    @top_ten_tags = ResourceCategory.top_tags_for_service_provider
    @all_tags = ResourceCategory.all_tags_service_provider({:limit => 1000, :offset => 0 })
  end

  def display_more_service_providers
    top_categories = ResourceCategory.published.find_by_title("Service Provider")
    limit = 11 + params[:display_more_check].to_i
    display_more_check =10 + params[:display_more_check].to_i
    render :partial => '/resources/service_category', :locals => {:resource_category => top_categories, :section_template => nil, :is_section_selected => false, :limit => limit, :display_more_check=>display_more_check}
  end

  def load_service_section_content
    section_template = SectionTemplate.find_by_id(params[:id])
    resource_ids = ''
    if section_template.id
      resource_ids = SectionTemplate.resource_ids(section_template.id)
    end
    #    currently not in scope becoz service provider dont have types
    @top_categories = ResourceCategory.published.find_by_title("Service Provider")
    #    @top_ten_categories = ResourceCategory.published.top_trending_service_provider({:resources=>resource_ids,:section_template_id => section_template.id})
    #   -------
    #    @top_ten_tags = ResourceCategory.top_tags_for_service_provider({:resources=>resource_ids,:section_template_id => section_template.id})
    @all_tags = ResourceCategory.all_tags_service_provider({:resources=>resource_ids,:section_template_id => section_template.id, :limit => 1000, :offset => 0})
    return render :partial => '/resources/middle', :locals => {:top_categories => @top_categories,:top_ten_categories => @top_ten_categories, :is_section_selected => true, :section_template => section_template.to_a, :top_ten_tags => @top_ten_tags, :all_tags => @all_tags, :is_resource_library => false, :is_default_page => false}
  end

  def load_right_category_content
    resource_category = ResourceCategory.find_by_id(params[:category_id])
    section_template = SectionTemplate.find_by_id(params[:section_id])
    if section_template.blank?
      return render :partial => '/resources/resource_category', :locals => {:resource_category => resource_category, :section_template => nil, :is_section_selected => false, :limit => 1000, :top_trending=> true}
    else
      return render :partial => '/resources/resource_category', :locals => {:resource_category => resource_category, :section_template => section_template, :is_section_selected => true, :limit => 1000,  :top_trending=> true}
    end
  end

  #  def load_tag_content
  #    tag = Tag.find_by_id(params[:tag_id].to_i)
  #    section_template = SectionTemplate.find_by_id(params[:section_id])
  #    if section_template.blank?
  #      if params[:is_resource_library] == "true"
  #        @resources = ResourceCategory.tag_resources_resource_library({:tag_id => tag.id, :is_top_tag => params[:is_top_tag]})
  #      else
  #        @resources = ResourceCategory.tag_resources_service_provider({:tag_id => tag.id, :is_top_tag => params[:is_top_tag]})
  #      end
  #      return render :partial => '/resources/tags', :locals => {:tag => tag, :resources => @resources}
  #    else
  #      if params[:is_resource_library] == "true"
  #        @resources = ResourceCategory.tag_resources_resource_library({:tag_id => tag.id, :is_top_tag => params[:is_top_tag],:section_template_id => section_template.id})
  #      else
  #        @resources = ResourceCategory.tag_resources_service_provider({:tag_id => tag.id,:is_top_tag => params[:is_top_tag], :section_template_id => section_template.id})
  #      end
  #      return render :partial => '/resources/tags', :locals => {:tag => tag, :resources => @resources}
  #    end
  #  end

  def load_section_category_content
    
    resource_category = ResourceCategory.find_by_id(params[:category_id].to_i)
    section_template = SectionTemplate.find_by_id(params[:section_id].to_i)
    if section_template.blank?
      return render :partial => '/resources/resource_category', :locals => {:resource_category => resource_category, :section_template => nil, :is_section_selected => false, :limit => 1000, :top_trending=> false}
      #      return render :partial => '/resources/resource_category', :locals => {:resource_category => resource_category, :section_template => nil, :is_section_selected => false}
    else
      return render :partial => '/resources/resource_category', :locals => {:resource_category => resource_category, :section_template => section_template, :is_section_selected => true, :limit => 1000, :top_trending=> false}
      #       return render :partial => '/resources/resource_category', :locals => {:resource_category => resource_category, :section_template => section_template, :is_section_selected => true}
    end
  end

  def load_all_content
    section_template = SectionTemplate.find_by_id(params[:id].to_i)
    if section_template.blank?
      @top_categories = ResourceCategory.published.all_categories_for_section_in_resource_library
      return render :partial => '/resources/resource', :locals => {:top_categories => @top_categories, :is_section_selected => false, :section_template => nil, :categories_count =>@top_categories.count}
    else
      @top_categories = ResourceCategory.published.all_categories_for_section_in_resource_library({:section_template_id => section_template.id})
      return render :partial => '/resources/resource', :locals => {:top_categories => @top_categories, :is_section_selected => true, :section_template => section_template, :categories_count =>@top_categories.count}
    end
  end
  
  def sorting
    #section_template = SectionTemplate.find_by_id(params[:id].to_i)
    is_resource_sorting = params[:is_resource_sorting]
    
    if is_resource_sorting == 'true'
      @section_templates = SectionTemplate.published.sequence_wise
      @top_ten_categories = ResourceCategory.published.top_trending_types_for_resource_library
      @top_ten_tags = ResourceCategory.top_tags_for_resource_library
      @all_tags = ResourceCategory.all_tags({:limit => 1000, :offset => 0 })
      render :partial => '/resources/middle', :locals => {:section_template => @section_templates,:top_ten_categories => @top_ten_categories, :top_ten_tags => @top_ten_tags, :all_tags => @all_tags, :is_section_selected => false, :is_resource_library => true, :is_default_page => true}
    else
      @section_templates = SectionTemplate.published.sequence_wise
      @top_categories = ResourceCategory.published.find_by_title("Service Provider")
      @top_ten_categories = ResourceCategory.published.top_trending_service_provider
      @top_ten_tags = ResourceCategory.top_tags_for_service_provider
      @all_tags = ResourceCategory.all_tags_service_provider({:limit => 1000, :offset => 0 })
      render :partial => '/resources/middle', :locals => {:section_template => @section_templates, :top_categories => @top_categories, :top_ten_categories => @top_ten_categories, :top_ten_tags => @top_ten_tags, :all_tags => @all_tags, :is_section_selected => false, :is_resource_library => false, :is_default_page => true}
    end
  end
  
  #---------Deprecation End--------------#

  def show_comments
    unless current_user.blank?
      @resource = Resource.find_by_id(params[:id])
      @comments = @resource.comments
      #resource.comments << comment
      return render :partial => '/resources/add_comments', :locals => {:comments => @comments, :resource => @resource}
    end
  end

  def add_comments
    unless current_user.blank?
      @resource = Resource.find_by_id(params[:id].to_i)
      comment_body = params[:comment_body]
      comment = Comment.new
      comment.body = comment_body
      comment.user = current_user
      @resource.comments << comment
      return render :partial => '/resources/add_comments', :locals => {:comments => @resource.comments, :resource => @resource}
    end
  end

  def thumbs_up
    @resource = Resource.find_by_id(params[:id].to_i)
    liking = Liking.new(:liking => 1)
    liking.user = current_user
    @resource.add_liking(liking)
    #count = @resource.likes_count
    return render :partial => '/resources/liking', :locals => {:resource => @resource}
  
  end

  def thumbs_down
    @resource = Resource.find_by_id(params[:id].to_i)
    liking = Liking.new(:liking => 0)
    liking.user = current_user
    @resource.add_liking(liking)
    return render :partial => '/resources/liking', :locals => {:resource => @resource}
  end

  def submit_resource
    resource = Resource.new
    @resource = Hash.new
    @resource[:company_name] = params[:company_name]
    @resource[:contact_name] = params[:contact_name]
    @resource[:email] = params[:email]
    unless @resource.blank?
      resource.deliver_submit_resource_email(@resource)
      return render :text => {:success => true}.to_json
    end
    return render :text => {:success => false}.to_json
  end
  def track_resource
    object = UserResourceClick.new
    object.resource_id=params[:resource_id]
    object.user_id=params[:user_id]
    object.ip_address = request.remote_ip.to_s rescue ''
    if object.save
      return render:text=>"Success"
    else
      return render:text=>"Fail"
    end

  end
  def publish
    resource = Resource.find params[:id]
    if resource.state.is_activated?
      resource.state = State.find_by_name('publish')
      resource.save
      flash[:notice] = "Resource successfully published"
    else
      flash[:notice] = "Resource is not publishable"
    end
    redirect_to list_resources_url
  end

  def activate
    resource = Resource.find params[:id]
    if resource.state.is_inactivated?
      resource.state = State.find_by_name('activate')
      resource.save
      flash[:notice] = "Resource successfully activated"
    else
      flash[:notice] = "Resource is not activatable"
    end
    redirect_to list_resources_url
  end

  def inactivate
    resource = Resource.find params[:id]
    if resource.state.is_inactivated?
      flash[:notice] = "Resource is not inactivatable"
    else
      resource.state = State.find_by_name('inactivate')
      resource.save
      flash[:notice] = "Resource successfully inactivated"
    end
    redirect_to list_resources_url
  end

  def remove_image
    resource = Resource.find params[:id]
    resource.content.destroy
    flash[:notice] = "Image is Removed"
    redirect_to edit_resource_path(resource)
  end

  def remove_banner
    resource = Resource.find params[:id]
    resource.banner.destroy
    flash[:notice] = "Banner is Removed"
    redirect_to edit_resource_path(resource)
  end

  private

  def load_content
    @resource_content = Hash.new
    @resource_content[:main_content] = MarketingTextMessage.find_by_page_and_location('resources','main_content')
    #    @resource_content[:resource_library_content] = MarketingTextMessage.find_by_page_and_location('resources','resource_library_content')
    #    @resource_content[:service_provider_content] = MarketingTextMessage.find_by_page_and_location('resources','service_provider_content')
    #    @resource_content[:resource_library_image] = MarketingMultimediaMessage.find_by_page_and_location("resources", 'resource_library_image')
    #    @resource_content[:service_provider_image] = MarketingMultimediaMessage.find_by_page_and_location("resources","service_provider_image")
    #    @section_templates = SectionTemplate.published.sequence_wise
    @resource_categories=ResourceCategory.published.sorted
  end
end
