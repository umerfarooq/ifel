class TemplateDocument < ActiveRecord::Base
  #belongs_to :template_category
  belongs_to :state

#  has_and_belongs_to_many :item_templates
#  has_and_belongs_to_many :items

  has_many :templatifications, :dependent => :destroy
  has_many :item_templates, :through => :templatifications

  has_attached_file :document,
    :url => "/admin/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:basename.:extension"

  attr_accessible :name, :title, :description, :document, :search_terms

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }
  named_scope :featured, :conditions => { :state_id => State.find_by_name('featurify').id }, :limit => MY_FILES_TEMPLATES_COUNT
  named_scope :featurified, :conditions => { :state_id => State.find_by_name('featurify').id }
  named_scope :date_wise, :order => "created_at DESC"
  named_scope :title_wise, lambda { |sort| {:order => "title #{sort}"}}
  named_scope :update_wise, lambda { |sort| {:order => "updated_at #{sort}"}}
  validates_presence_of :title#, :template_category

  validates_attachment_presence     :document
  validates_attachment_size         :document, :less_than => 100.megabytes, :if => Proc.new { |record| !record.document_file_name.blank? }, :message => "must be less than 100 megabytes"
  validates_attachment_content_type :document, :content_type => FILE_TYPE_ALL_OFFICE + FILE_TYPE_IMAGE + FILE_TYPE_PDF, :if => Proc.new { |record| !record.document_file_name.blank? }, :message => "must be one of the MS-Office documents type"

  before_create :set_creation_defaults
  
  def self.get_template_documents
    obj_template_documents = TemplateDocument.all
    bln_success = 0
    if (obj_template_documents)
      bln_success = 1
    end
    return obj_template_documents, bln_success
  end

  def self.get_template_document(id)
    obj_template_document = TemplateDocument.find_by_id(id)
    bln_success = 0
    if (obj_template_document)
      bln_success = 1
    end
    return obj_template_document, bln_success
  end

  define_index do
    indexes title
    indexes name
    indexes description
    indexes search_terms
#    indexes user_id
    set_property :delta => true
  end
  
  
  private
  def set_creation_defaults
    self.state = State.inactivated
  end

end
