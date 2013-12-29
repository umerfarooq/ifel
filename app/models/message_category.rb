class MessageCategory < ActiveRecord::Base
  has_many :messages, :dependent => :destroy
  belongs_to :state

  attr_accessible :name, :title, :description
  validates_presence_of :title

  named_scope :published, :conditions => {:state_id => [State.find_by_name('publish').id]}

#  def MessageCategory.all_active
#    MessageCategory.find_all_by_is_active(true, :order => 'title ASC')
#  end
end
