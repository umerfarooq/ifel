class Note < ActiveRecord::Base
  belongs_to :item

  named_scope :date_wise, :order=>"created_at DESC"

  validates_presence_of :description
end
