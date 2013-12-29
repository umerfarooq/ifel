class Resourcification < ActiveRecord::Base
  belongs_to :item_template
  belongs_to :resource
  belongs_to :state

  before_create :set_creation_defaults

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }
  
#  def self.resources_associated_to_all_items_of_the_section(options={})
#    item_templates = options[:section].item_templates
#    published_state = State.published
#    Resourcification.find(:all,
#      :select=>"resource_categories.title AS category_title,resource_categories.id AS category_id,resources.*",
#      :joins=>"INNER JOIN resources ON resourcifications.resource_id = resources.id
#             INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id#",
#      :conditions=>["resourcifications.item_template_id IN(?) AND resourcifications.state_id=? AND resources.state_id=?",item_templates.collect(&:id), published_state.id, published_state.id],
#      :group=>"resources.id",
#      :order=>"resource_categories.title,resources.title",
#      :limit=>options[:limit] || 10
#    )    
#  end
  
  private
  def set_creation_defaults
    self.state_id = (State.find_by_name("activate")).id
  end

end
