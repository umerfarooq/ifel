class EventsProvider < ActiveRecord::Base

  belongs_to :state
  has_many :events, :dependent => :destroy
  has_many :feeds, :as => :feeder, :dependent => :destroy

  before_save :url_absolutify
  before_create :set_creation_defaults

  has_attached_file :logo, :styles => { :small => "100x100>", :medium => "150x150>", :large => "300x200>", :featured => "215x215>" },
    :url => "/admin/events_providers/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/events_providers/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/events_providers/:attachment/missing_:style.png"

  named_scope :published, :conditions => {:state_id => State.find_by_name('publish').id}
  named_scope :date_wise, :order => 'updated_at DESC'
  named_scope :title_wise, :order => 'title ASC'

  #attr_accessible       :title, :url, :rss_link, :logo
  validates_presence_of :title, :url

#  validates_length_of   :name,  :maximum => 250
#  validates_length_of   :url,   :maximum => 250

  validates_attachment_presence     :logo
  validates_attachment_size         :logo, :less_than => 10.megabytes, :unless => Proc.new { |r| r.logo_file_name.blank? }
  validates_attachment_content_type :logo, :content_type => FILE_TYPE_IMAGE, :unless => Proc.new { |r| r.logo_file_name.blank? }


  validates_length_of       :rss_link,            :maximum => 250,        :unless => "rss_link.blank?"

  def url_absolutify
    self.url = "http://#{self.url}" unless (self.url[0..3] == "http")
  end

  def set_creation_defaults
     self.state = State.inactivated
  end

  def published?
    self.state.is_published?
  end

  def activated?
    self.state.is_activated?
  end

  def inactivated?
    self.state.is_inactivated?
  end

    def publish
    if self.state.is_activated?
      self.state = State.published
      return self.save
    else
      return false
    end
  end

  def activate
    if self.state.is_inactivated?
      self.state = State.activated
      return self.save
    else
      return false
    end
  end

  def inactivate
    if self.state.is_inactivated?
      return false
    else
      self.state = State.inactivated
      return self.save
    end
  end


  def self.size_list
    ['small', 'medium', 'large', 'featured']
  end


end
