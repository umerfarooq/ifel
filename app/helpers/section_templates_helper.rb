module SectionTemplatesHelper
  def helper_section_template_resource_description(section_id)
    SectionTemplate.find(section_id.to_i).resource_text_message.description rescue ''
  end
  
  def helper_get_resources_associated_to_section_template(section_template)
    Resourcification.resources_associated_to_all_items_of_the_section({:section=>section_template})
  end
end
