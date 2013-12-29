class NewsProvider < ActiveRecord::Base
  belongs_to :state
  has_many :news_articles, :dependent => :destroy
  has_many :feeds, :as => :feeder, :dependent => :destroy

  before_save :url_absolutify
  before_create :set_creation_defaults

  has_attached_file :logo, :styles => { :small => "100x100>", :medium => "150x150>", :large => "300x200>", :featured => "215x215>" },
    :url => "/admin/news_providers/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/news_providers/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/news_providers/:attachment/missing_:style.png"

  #  named_scope :on_the_radar_rss_providers, :conditions => ["is_rss_provider = ? AND feed_count > 0 AND state_id = ?", true, State.find_by_name('publish').id], :order => 'sequence_number DESC'
  #  named_scope :front_module_rss_providers, :conditions => ["is_rss_provider = ? AND front_module_count > 0 AND state_id = ?", true, State.find_by_name('publish').id], :order => 'sequence_number DESC'
  named_scope :rss_providers, :conditions => {:is_rss_provider => true}
  named_scope :has_radar_feeds, :conditions => ["feed_count > 0"]
  named_scope :has_launchpad_feeds, :conditions => ["front_module_count > 0"]
  named_scope :published, :conditions => {:state_id => State.find_by_name('publish').id}
  named_scope :sequence_wise, :order => 'sequence_number DESC'

#  attr_accessible       :title, :url, :rss_link, :feed_count, :front_module_count, :logo
  validates_presence_of :title, :url

#  validates_length_of   :name,  :maximum => 250
#  validates_length_of   :url,   :maximum => 250

  validates_attachment_presence     :logo
  validates_attachment_size         :logo, :less_than => 10.megabytes, :unless => Proc.new { |r| r.logo_file_name.blank? }
  validates_attachment_content_type :logo, :content_type => FILE_TYPE_IMAGE, :unless => Proc.new { |r| r.logo_file_name.blank? }


  validates_presence_of :rss_link, :feed_count, :front_module_count, :if => "is_rss_provider"
  validate :must_be_feed_provider, :if => "is_rss_provider"

  validates_length_of       :rss_link,            :maximum => 250,        :unless => "rss_link.blank?"
  validates_numericality_of :feed_count,          :only_integer => true,  :unless => "feed_count.blank?"
  validates_numericality_of :front_module_count,  :only_integer => true,  :unless => "front_module_count.blank?"


  def url_absolutify
    self.url = "http://#{self.url}" unless (self.url[0..3] == "http")
  end

  def set_creation_defaults
    if NewsProvider.all.blank?
      self.sequence_number = 1
    else
      self.sequence_number = NewsProvider.maximum('sequence_number') + 1
    end
    self.state = State.inactivated
  end

  def NewsProvider.for_news_articles
    NewsProvider.find_all_by_is_rss_provider_and_state_id(false, State.find_by_name('publish').id)
  end

  def rss_provider?
    self.is_rss_provider
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

  def on_top?
    self.sequence_number == NewsProvider.maximum(:sequence_number)
  end

  def on_bottom?
    self.sequence_number == NewsProvider.minimum(:sequence_number)
  end

  def move_up
    if self.sequence_number < NewsProvider.maximum(:sequence_number)
      one_up_sno = NewsProvider.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      provider_swap = NewsProvider.find_by_sequence_number(one_up_sno)
      provider_swap.sequence_number = self.sequence_number
      self.sequence_number = one_up_sno
      self.save
      provider_swap.save
      return true
    else
      return false
    end
  end

  def move_down
    if self.sequence_number > NewsProvider.minimum(:sequence_number)
      one_down_sno = NewsProvider.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      provider_swap = NewsProvider.find_by_sequence_number(one_down_sno)
      provider_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      provider_swap.save
      return true
    else
      return false
    end
  end

  def self.size_list
    ['small', 'medium', 'large', 'featured']
  end

  private
  def must_be_feed_provider
    begin
      require 'feed_validator'
      v = W3C::FeedValidator.new()
      v.validate_url(self.rss_link)
    rescue REXML::ParseException
      errors.add(:rss_link, "must be a valid feed provider's link")
    rescue
      errors.add(:rss_link, "could not be validated")
    else
      errors.add(:rss_link, "must be a valid feed provider's link") unless v.valid?
    end
  end

end
