module ItemsHelper
  def helper_item_title_suffixed_by_sequence(item)
    "#{item.sequence_number.to_s}. #{item.title}" if item.present?
  end
  def helper_get_state_icon_name(item)
    icon_name = ""
    if item.is_not_applicable
      icon_name = 'notapplicable'
    else
      if item.completed?
        icon_name = 'complete'
      elsif !item.completed?
        icon_name = 'inprogress'
      end
    end
    icon_name
  end
  def helper_get_state_icon_name_roadmap(item)
    icon_name = 'item-untouched'
    if item.is_not_applicable
      icon_name = 'item-notapplicable'
    elsif item.completed?
      icon_name = 'item-complete'
    elsif item.edited?
      icon_name = 'item-inprogress'
    end
    icon_name
  end
  def helper_is_first_item?(item)
    item.is_first_in_the_project?
  end
  def helper_is_last_item?(item)
    item.is_last_in_the_project?
  end
  def helper_get_predecessor(item)
    item.predecessor
  end
  def helper_get_successor(item)
    item.successor
  end
  def helper_item_title_suffix_with_section_sequence(item)
    "#{item.section.sequence_number.to_s}.#{item.sequence_number.to_s} #{item.title.to_s}"
  end
  def helper_resource_description_exceeding_allowed_height?(description)
    description.length > 600
  end
  def helper_download_path(object)
    (object.class==TemplateDocument) ? download_template_document_path(object) : download_example_path(object)
  end
  
  def helper_template_example_title(object)
    (object.class==TemplateDocument) ? object.title : object.name
  end
  
  def helper_resource_snapshot(item)
    snapshot = ""
    section_seq = item.section.sequence_number
    if section_seq == 1
      snapshot = "resource_snapshots/item-1.#{item.sequence_number.to_s}.png"
    else
      snapshot = "resource_snapshots/item-#{section_seq.to_s}.png"
    end
  end
  
end
