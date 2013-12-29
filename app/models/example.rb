class Example < ActiveRecord::Base
#  belongs_to :example_category
  belongs_to :state
#  has_and_belongs_to_many :items
  belongs_to :item_template

  has_attached_file :document,
    :url => "/admin/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:basename.:extension"

  attr_accessible :name, :description, :document, :search_terms

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }
  named_scope :date_wise, :order => "created_at DESC"

  validates_attachment_presence     :document
  validates_attachment_size         :document, :less_than => 100.megabytes, :if => Proc.new { |record| !record.document_file_name.blank? }, :message => "must be less than 100 megabytes"
  validates_attachment_content_type :document, :content_type => FILE_TYPE_PDF, :if => Proc.new { |record| !record.document_file_name.blank? }, :message => "must be PDF"

  define_index do
    indexes description
    indexes name
    indexes search_terms
#    indexes user_id
    set_property :delta => true
  end

  def title
    return name
  end
end
