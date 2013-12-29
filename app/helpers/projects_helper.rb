module ProjectsHelper
  def helper_get_class_name(object)
    class_name = object.class.name
    if object.class == TemplateDocument
      class_name = 'Template'
    end
    if object.class == Comment or object.class == Message
      class_name = 'Community'
    end
    return class_name
  end
  def helper_get_summary(object)
    (object.class == Message or object.class == Comment) ? object.body : object.description
  end
  def helper_get_link(object)
    path = String.new
    if object.class == Message
#      path = message_path(object)
      path = feedwall_path(:is_msg_partial=>true, :message_for_detail=>object.id.to_s)
    elsif object.class == Comment
#      path = message_comments_path(object)
      path = feedwall_path(:is_msg_partial=>true, :message_for_detail=>object.message.id.to_s)
    elsif object.class == Resource
      path = object.url
    elsif object.class == TemplateDocument
      path = object.document.url
    elsif object.class == Example
      path = download_example_path(object)
    end
    return path
  end
  def helper_get_target(object)
    target = '_self'
    if object.class == Resource or object.class == TemplateDocument or object.class == Example
      target = '_blank'
    end
    return target
  end
  
  def helper_datewise_percentage(project)
    percentage = 100
    total_days = (project.end_date-project.start_date)
    days_spent = (Date.today-project.start_date)
    counted_percentage = (days_spent*100).to_f/total_days.to_f
    percentage = counted_percentage unless counted_percentage > 100.to_f
    percentage
  end
  
  def helper_is_overdue?(project)
    is_overdue = false
    project.sections.each do |section|
      if section.due_date and section.due_date < Date.today
        if !section.completed? and !section.ended?
          is_overdue = true
        end
      end
    end
    is_overdue
  end
  
  def helper_is_no_progress_at_all?(project)
    if project.percent > 0
      return false
    else
      return true
    end
  end

  def helper_items_to_print(section, items_type)
    items = nil
    case items_type
    when 'all_items'
      items = section.items
    when 'inprogress_items'
      items = section.items.are_not_complete.are_in_progress
    when 'completed_items'
      items = section.items.completed
    when 'incompleted_items'
      items = section.items.are_not_complete
    end
    items
  end

  def helper_get_appropriate_resource_panel_action(resource, section)
    if resource.url.present?
      return link_to(image_tag('learn-more.png'),resource.url, :target => '_blank')
    else
      return link_to(image_tag('preview-btn.png'),"#{resource_library_resources_path}##{section.title.downcase.gsub(' ','_')}", :target => '_blank')
    end
  end
  
end
