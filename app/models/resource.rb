require 'htmlentities'
class Resource < ActiveRecord::Base
  acts_as_taggable
  acts_as_commentable
  acts_as_likeable

  belongs_to :resource_category
  belongs_to :state
  #  has_and_belongs_to_many :items
  #  has_and_belongs_to_many :item_templates
  attr_accessor :pricing

  has_many :resourcifications
  has_many :item_templates, :through => :resourcifications
  has_many :resource_pricings
  has_many :pricings, :through => :resource_pricings
  #  before_create :set_creation_defaults

  before_save :url_absolutify, :banner_url_absolutify, :decode_html_entities

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }
  named_scope :date_wise, :order => "created_at DESC"
  named_scope :sorted, :order => "title ASC"
  named_scope :title_wise,lambda {|sort|  {:order => "title #{sort}"} }
  named_scope :only,lambda {|number| {:limit => number}}
  
  #named_scope :resource_library_type, :conditions => ['resource_category_id !=?', ResourceCategory.service_provider_type.id]
  #named_scope :service_provider_type, :conditions => ['resource_category_id =?', ResourceCategory.service_provider_type.id]

  has_attached_file :content, :styles => { :resource_library => "75x115", :service_provider => "180x180" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :banner, :styles => { :service_provider => "150x150" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"
  #  def set_creation_defaults
  #    self.is_active = true
  #    self.state_id = (State.find_by_title("create")).id
  #  end

  attr_accessor :body
  validates_presence_of :resource_category_id, :title
  #validates_attachment_presence     :content
  validates_attachment_size         :content, :less_than => 10.megabytes, :if => Proc.new { |record| !record.content_file_name.blank? }
  validates_attachment_content_type :content, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.content_file_name.blank? }

  validates_attachment_size         :banner, :less_than => 10.megabytes, :if => Proc.new { |record| !record.banner_file_name.blank? }
  validates_attachment_content_type :banner, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.banner_file_name.blank? }

  
  def self.resource_library_type(sort)
    Resource.find(:all, :joins => :resource_category, :conditions=>['resource_category_id !=? and resource_categories.state_id =?', ResourceCategory.service_provider.id, 3 ], :order => "title #{sort}")
  end

  def self.service_provider_type(sort)
    Resource.find(:all, :joins => :resource_category, :conditions=>['resource_category_id =? and resource_categories.state_id =?', ResourceCategory.service_provider.id, 3 ], :order => "title #{sort}")
  end

  def is_service_provider_type?
    self.resource_category_id  == ResourceCategory.service_provider.id
  end
  
  def url_absolutify
    unless (self.url[0..3] == "http")
      self.url = "http://#{self.url}"
    end
  end
  
  def decode_html_entities
    coder = HTMLEntities.new
    unless self.html_banner.blank?
      self.html_banner=coder.decode(self.html_banner)
    end
    unless self.html_url.blank?
      self.html_url=coder.decode(self.html_url)
    end
    unless self.html_image.blank?
      self.html_image=coder.decode(self.html_image)
    end
  end

  def has_image?
    if self.content_file_name.blank?
      return false
    else
      return true
    end
  end

  def banner_url_absolutify
    unless self.banner_url.blank?
      unless (self.banner_url[0..3] == "http")
        self.banner_url = "http://#{self.banner_url}"
      end
    end
  end


  # functions for dashboard
  def self.top_trending()
    joins = []
    conditions = ["resources.created_at >=? and resources.state_id =? and resourcifications.state_id =?",(Date.today-(1.month)), 3, 3]
    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #    joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #
    #    end
    Resource.find(
      :all,
      :select => 'resources.id, COUNT(resources.id) AS no_of_resources_in_a_month',
      :joins => joins,
      :conditions => conditions,
      :group => 'resources.id',
      :order => 'no_of_resources_in_a_month DESC')
    #      :limit => options[:limit] || 10)
  end



  def self.top_trending_resources_by_section(section_id)
    joins = []
    joins << "INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    joins << "INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    joins << "INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"

    self.published.find(
      :all,
      :select => 'resources.*, section_templates.id AS section',
      :joins => joins,
      :conditions => ["resources.created_at >=? and resourcifications.state_id =? AND section_templates.id =?", (Date.today-(1.month)), 3 ,section_id],
      :group => 'resources.id',
      :order => 'section ASC')
    #      :limit => options[:limit] || 3)
  end



  def url_absolute
    (self.url[0..3] == "http") ? self.url : "http://#{self.url}"
  end

  def self.get_resources
    obj_resources = Resource.all
    bln_success = 0
    if (obj_resources)
      bln_success = 1
    end
    return obj_resources, bln_success
  end

  def self.get_resource(id)
    obj_resource = Resource.find_by_id(id)
    bln_success = 0
    if (obj_resource)
      bln_success = 1
    end
    return obj_resource, bln_success
  end

  def deliver_submit_resource_email(resource)
    UserMailer.deliver_submit_resource_email(resource)
  end

  define_index do
    where "state_id != 1"
    indexes description
    indexes title
    indexes name
    indexes search_terms
    indexes taggings.tag.name
    #    indexes user_id
    set_property :delta => true
  end
end
