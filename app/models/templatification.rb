class Templatification < ActiveRecord::Base
  belongs_to :item_template
  belongs_to :template_document
  belongs_to :state

  before_create :set_creation_defaults

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }

  def set_creation_defaults
    self.state_id = (State.find_by_name("activate")).id
  end

end
