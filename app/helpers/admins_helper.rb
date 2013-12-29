module AdminsHelper
  def helper_display_items_concatenated_with_sections
    ItemTemplate.get_item_template_along_with_section_template_name
  end

  def helper_display_sections
    SectionTemplate.all
  end
  
  def helper_display_topics
    Topic.all
  end

  def orphan_topic
    Topic.find_all_by_is_orphan(true)
  end
end
