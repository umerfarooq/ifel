class NewsArticle < ActiveRecord::Base
  belongs_to :news_provider
  belongs_to :state
  belongs_to :events_provider

  ABOUTUS_PAGE_COUNT = 3
  HOME_PAGE_COUNT = 3

  before_create :set_creation_defaults

  named_scope :published, :conditions => {:state_id => State.find_by_name('publish').id}
  named_scope :limit_launchpad, :limit => FRONT_MODULES_RADAR_PUBLIC_COUNT
  named_scope :date_wise, :order => 'news_date DESC'
  named_scope :featured, :conditions => {:state_id => State.featurified.id}
  named_scope :no_of_records, lambda{|number| {:limit=>number}}

  attr_accessible         :news_date, :title, :url, :summary, :description
  validates_presence_of   :news_date, :title, :url, :summary, :description, :news_provider

#  attr_accessible         :news_date, :headline, :brief, :summary, :body, :url
#  validates_presence_of   :news_date, :headline, :brief, :summary, :body, :url, :news_provider
#
#  validates_length_of     :headline,  :maximum => 250
#  validates_length_of     :brief,     :maximum => 65000
#  validates_length_of     :summary,   :maximum => 65000
#  validates_length_of     :body,      :maximum => 65000
#  validates_length_of     :url,       :maximum => 250
#
#  #  validate :must_belong_to_provider
#
#  def url_absolutify
#    self.url = "http://#{self.url}" unless (self.url[0..3] == "http")
#  end
#
#  def description
#    return summary
#  end
#
#  def title
#    return headline
#  end

  def set_creation_defaults
    self.state = State.inactivated
  end

  def NewsArticle.events_page_article
    NewsArticle.published.date_wise.first
  end

  def NewsArticle.about_us_page_articles
    NewsArticle.published.date_wise.all(:limit => NewsArticle::ABOUTUS_PAGE_COUNT)
  end

  def NewsArticle.home_page_articles
    NewsArticle.published.date_wise.all(:limit => NewsArticle::HOME_PAGE_COUNT)
  end

  def self.shuffle_featured_articles(limit)
    return NewsArticle.featured if NewsArticle.featured.length <= limit
    return NewsArticle.featured.shuffle[1..limit]
  end

  def internal?
    self.is_internal == true
  end

  def featurified?
    self.state.is_featurified?
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

  def featurify
    if self.state.is_published?
      self.state = State.featurified
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

end
