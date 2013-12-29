class DocumentCategory < ActiveRecord::Base
  has_many :documents
  belongs_to :state
  attr_accessible :name, :title, :description
  validates_presence_of :title
end
