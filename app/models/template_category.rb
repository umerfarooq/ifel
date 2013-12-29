class TemplateCategory < ActiveRecord::Base
  belongs_to :state
  has_many :template_documents, :dependent => :destroy

#  before_create :set_creation_defaults

  attr_accessible :name, :title, :description

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }

  validates_presence_of :title

#  def set_creation_defaults
#    self.is_active = true
#    self.state_id = (State.find_by_title("create")).id
#  end
#
#  def TemplateCategory.all_active
#    TemplateCategory.find_all_by_state_id((State.find_by_title("create")).id)
#  end
end
