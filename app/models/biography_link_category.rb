class BiographyLinkCategory < ActiveRecord::Base
  belongs_to :state

  attr_accessible :title, :description
  #  :sequence_number

  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :sequence_wise, :order => 'sequence_number ASC'

end
