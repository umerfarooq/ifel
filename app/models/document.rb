class Document < ActiveRecord::Base
  acts_as_taggable
  belongs_to :state
  belongs_to :documentable, :polymorphic => true #Documents/Files have Polymorphic Assocations with Sections/Items
  has_attached_file :data,
    :url => "/client/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/client/:class/:attachment/:id/:basename.:extension"
  named_scope :latest, :order => "created_at DESC", :limit => 3
  named_scope :recently_modified, :order => "updated_at DESC"
  named_scope :date_wise, :order => "created_at DESC"

  attr_accessible :data, :is_note
  validates_presence_of :documentable_id
  validates_presence_of :documentable_type, :unless => Proc.new { |record| record.documentable_id.blank? }
  validates_attachment_presence     :data
  validates_attachment_size         :data, :less_than => MAXSIZE_USER_DOCUMENT, :if => Proc.new { |record| !record.data_file_name.blank? }
  validates_attachment_content_type :data, :content_type => FILE_TYPE_USER_DOCUMENT, :if => Proc.new { |record| !record.data_file_name.blank? }
  before_create :set_default_state, :set_default_name

  def set_default_state
    self.state = State.inprogress
  end
  
  def set_default_name
    name = ""
    # Only when a File is been Uploaded
    unless self.data_file_name.blank?
      splitted_filename = self.data_file_name.split('.')
      self.name = name = splitted_filename[0]
    end
    return name
  end

  def document_category
    if self.documentable.class == Item
      self.documentable.section
    else # self.documentable.class == Section
      self.documentable
    end
  end

  def owner
    if self.documentable.class == Item
      self.documentable.section.project.user
    else # self.documentable.class == Section
      self.documentable.project.user
    end
  end

  # TODO # del_lines(12) # jul_02
  #  def document_category_id
  #    if self.documentable.class == Item
  #      self.documentable.section_id
  #    else # self.documentable.class == Section
  #      self.documentable_id
  #    end
  #  end
  #
  #  def document_category_id=(value)
  #    self.documentable_id = value
  #    self.documentable_type = Section
  #  end
  #
  def url(*args)
    self.data.url(*args)
  end

  def path
    self.data.path
  end

  #  def name
  #    self.data_file_name
  #  end

  def content_type
    self.data_content_type
  end

  def file_size
    self.data_file_size
  end

  def uploaded_at
    self.data_updated_at
  end

  def self.get_documents_and_templates(user_id)
    obj_current_user = User.find_by_id(user_id)
    bln_success = 0
    if(obj_current_user)
      if(obj_current_user.project)
        if(obj_current_user.project.documents)
          obj_documents = obj_current_user.project.documents
        end
      end
    end
    obj_templates = TemplateDocument.all
    if (obj_documents && obj_templates)
      bln_success = 1
    end
    return obj_documents, obj_templates , bln_success
  end

  def self.get_document(id)
    obj_document = self.documents
    bln_success = 0
    if (obj_document)
      bln_success = 1
    end
    return obj_document, bln_success
  end

  def is_inprogress?
    self.state.is_inprogress?
  end

  def is_completed?
    self.state.is_completed?
  end

  def self.search_documents(options, request)
    item_ids = Array.new
    section_ids = Array.new
    sections = options[:current_user].project.sections
    sections.each { |sec| item_ids |= sec.items.collect { |i| i.id  } }
    section_ids = item_ids | sections.collect{|section| section.id}
    query = options[SEARCH_FIELD.to_sym]
    search_results = Document.search(
      query,
      :conditions => {:documentable_type => "(Section) | (Item)"},
      :with => {:documentable_id => section_ids },
      :retry_stale => true,
      :populate => true)
    SearchTerm.searched(query, request.referer, 'internal')
    return search_results
  end

  def self.get_with_file_name(filename, section_id)
    #    Document.find_by_data_file_name_and_documentable_type_and_documentable_id(filename,'Section',section_id)
    Document.find(:first, :select=>'id', :conditions => {:data_file_name => filename, :documentable_type => 'Section', :documentable_id => section_id.to_i})
  end

  #  def get_section_id
  #    if self.documentable_type == 'Section'
  #      self.documentable_id
  #    else
  #      self.documentable.section_id
  #    end
  #  end
  
  def deliver_share_document_email(document)
    filepath = Rails.root.join('public','client','documents','datas',self.id.to_s,self.data_file_name)
    AdminMailer.deliver_share_document_email(document, filepath)
  end

  define_index do
    indexes :name
#    indexes tags(:name)
    indexes taggings.tag.name

    #indexes :data_file_name
    #    indexes :id, :sortable => true
    #    indexes title
    #    indexes keywrds
    #    indexes celebrities.name,:as=>:celeb_name
    #    indexes movies.name
    #    indexes tvshows.name
    #    indexes categories.category_id, :as=>:cat_parent
    #    indexes categories(:id), :as=>:cat_id
    #    indexes status
    #    indexes description
    #    indexes :created_at, :sortable => true
    #    has "RADIANS(latitude)",  :as => :latitude,  :type => :float
    #    has "RADIANS(longitude)", :as => :longitude, :type => :float
    has :documentable_id
    set_property :delta => true
  end
  
end
