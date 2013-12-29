class TopicsController < ApplicationController
  before_filter(:only => [:new, :edit, :create,:update,:index]) { |c| c.active_tab = :account_tab }
  
  
  def index
    @topics = Topic.all
  end

  def new
    @topic= Topic.new
  end

  def create    
    params[:user_id] = current_user.id
    if Topic.save_or_update_and_associate(params)
      return render :text => {:success => true}.to_json
    else
      return render :text => {:success => false}.to_json
    end
  end

  def topic_items_on_category
    if request.xhr?
      render :partial=> "admins/topic_items", :locals=>{:items => ItemTemplate.find_all_by_section_template_id(params[:category])}
    end
  end

  def select_topic_on_item
    item_template = ItemTemplate.find(params[:item])
    template_topics = item_template.item_templates_topics
    if request.xhr?
      render :partial=> "admins/topics_according_to_item_list", :locals=>{:topics =>template_topics}
    end
  end

  def select_topic_on_section
    section_template = SectionTemplate.find(params[:section])
    template_topics = section_template.section_templates_topics
    if request.xhr?
      render :partial=> "admins/topics_according_to_section_list", :locals=>{:topics =>template_topics}
    end
  end

  def create_orphan_topic
    topic = Topic.new
    topic.name = params[:name]
    topic.is_orphan = true
    topic.state_id = State.find_by_name('inactivate')
    topic.user = current_user
    if topic.save
      topic.deliver_add_topic_email
      return render :text => {:success => true}.to_json
    else
      return render :text => {:success => false, :error => topic.errors.first[1]}.to_json
    end
  end
  
  def edit
    @topic = Topic.find params[:id]
  end

  def activate_orphan_topic
    @topic = Topic.find params[:id]
  end

  def activate_orphan
    topic = Topic.find params[:id]
    if params[:topic][:item_template].present?
      item_templates = Array.new
      #      item_template_ids = params[:item_template].split(',')
      params[:topic][:item_template].each do |i|
        item_templates << ItemTemplate.find(i.to_i)
      end
    end
    topic.item_template = item_templates
    topic.is_orphan = false
    if topic.save
      flash[:success] = "Topic successfully updated"
    else
      flash[:notice] = "Topic could not be updated"
    end
    redirect_to :controller=>"admins", :action=>"community_tab"
  end
  
  def update
    #    topic = Topic.find params[:id]
    #    topic.name = params[:topic][:name]
    #
    #    if params[:topic][:item_template].present?
    #      item_templates = Array.new
    #      #      item_template_ids = params[:item_template].split(',')
    #      params[:topic][:item_template].each do |i|
    #        item_templates << ItemTemplate.find(i.to_i)
    #      end
    #    end
    #
    #    topic.item_template = item_templates
    #
    #    if topic.save
    #      flash[:success] = "Topic successfully updated"
    #    else
    #      flash[:notice] = "Topic could not be updated"
    #    end

    topic = Topic.find params[:id]
    if topic.update_attributes(params[:topic])
      flash[:success] = "Topic successfully updated"
      redirect_to topics_path
    else
      flash[:notice] = "Topic could not be updated"
      redirect_to edit_topic_path(topic)
    end
  end
  
  def destroy
    @topic = Topic.find params[:id]
    if @topic.destroy
      flash[:success] = "Topic is deleted."
    else
      flash[:notice] = "Topic can't be deleted."
    end
    return redirect_to :back
  end

  def list
    @topic = Topic.new
    @topics = Topic.all
    respond_to do |format|
      format.html { render :action => 'list' }
      format.js { render :text => {:topics => Topic.publish.map(&:token_inputs)}.to_json }
    end

  end

  def publish
    topic = Topic.find params[:id]
    if topic.publish
      flash[:success] = "Topic successfully published"
    else
      flash[:notice] = "Topic is not publishable"
    end
    return redirect_to :back
  end

  def activate
    topic = Topic.find params[:id]
    
    if topic.activate
      flash[:success] = "Topic is successfully activated"
    else
      flash[:notice] = "Topic is not activatable"
    end
    return redirect_to :back
  end

  def change_state
    @topic = Topic.find_by_id(params[:id])
    @topic.state = State.find_by_title(params[:state])
    if @topic.save
    else
    end
    redirect_to :controller=>"admins", :action=>"community_tab"
  end

  def inactivate
    topic = Topic.find params[:id]
    
    if topic.messages.blank?
      if topic.inactivate
        flash[:success] = "Topic successfully inactivated"
      else
        flash[:notice] = "Topic is not inactivatable"
      end
    else
      flash[:notice] = "Topic has messages in it so cannot be inactivated"
    end
    return redirect_to :back
  end

  def mark_template_as_default
    template_topic = nil
    template_parent = nil
    if params[:type]=='section'
      template_topic=SectionTemplatesTopic.find(params[:id])
      template_parent = SectionTemplate.find(template_topic.section_template_id)
      topics = template_parent.section_templates_topics
      page_to_render = "admins/topics_according_to_section_list"
    else
      template_topic=ItemTemplatesTopic.find(params[:id])
      template_parent = ItemTemplate.find(template_topic.item_template_id)
      topics = template_parent.item_templates_topics
      page_to_render = "admins/topics_according_to_item_list"
    end
    template_topic.update_attribute(:is_default, true)
    render :partial=> page_to_render, :locals=>{:topics =>topics}
  end

  def unmark_template_as_default
    template_topic = nil
    template_parent = nil
    if params[:type]=='section'
      template_topic=SectionTemplatesTopic.find(params[:id])
      template_parent = SectionTemplate.find(template_topic.section_template_id)
      topics = template_parent.section_templates_topics
      page_to_render = "admins/topics_according_to_section_list"
    else
      template_topic=ItemTemplatesTopic.find(params[:id])
      template_parent = ItemTemplate.find(template_topic.item_template_id)
      topics = template_parent.item_templates_topics
      page_to_render = "admins/topics_according_to_item_list"
    end
    template_topic.update_attribute(:is_default, false)
    render :partial=> page_to_render, :locals=>{:topics =>topics}
  end

  def inactivate_template
    template_topic = nil
    template_parent = nil
    if params[:type]=='section'
      template_topic=SectionTemplatesTopic.find(params[:id])
      template_parent = SectionTemplate.find(template_topic.section_template_id)
      topics = template_parent.section_templates_topics
      page_to_render = "admins/topics_according_to_section_list"
    else
      template_topic=ItemTemplatesTopic.find(params[:id])
      template_parent = ItemTemplate.find(template_topic.item_template_id)
      topics = template_parent.item_templates_topics
      page_to_render = "admins/topics_according_to_item_list"
    end
    template_topic.inactivate
    render :partial=> page_to_render, :locals=>{:topics =>topics}
  end

  def activate_template
    template_topic = nil
    template_parent = nil
    if params[:type]=='section'
      template_topic=SectionTemplatesTopic.find(params[:id])
      template_parent = SectionTemplate.find(template_topic.section_template_id)
      topics = template_parent.section_templates_topics
      page_to_render = "admins/topics_according_to_section_list"
    else
      template_topic=ItemTemplatesTopic.find(params[:id])
      template_parent = ItemTemplate.find(template_topic.item_template_id)
      topics = template_parent.item_templates_topics
      page_to_render = "admins/topics_according_to_item_list"
    end
    template_topic.activate
    render :partial=> page_to_render, :locals=>{:topics =>topics}
  end

  def publish_template
    template_topic = nil
    template_parent = nil
    if params[:type]=='section'
      template_topic=SectionTemplatesTopic.find(params[:id])
      template_parent = SectionTemplate.find(template_topic.section_template_id)
      topics = template_parent.section_templates_topics
      page_to_render = "admins/topics_according_to_section_list"
    else
      template_topic=ItemTemplatesTopic.find(params[:id])
      template_parent = ItemTemplate.find(template_topic.item_template_id)
      topics = template_parent.item_templates_topics
      page_to_render = "admins/topics_according_to_item_list"
    end
    template_topic.publish
    render :partial=> page_to_render, :locals=>{:topics =>topics}
  end

end
