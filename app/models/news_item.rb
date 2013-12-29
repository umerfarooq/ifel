class NewsItem < ActiveRecord::Base
  @@summary_length = 200
  @@title_length = 20

  belongs_to :news_category
  belongs_to :news_provider
  belongs_to :state

  has_attached_file :document,
    :url => "/admin/news_items/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/news_items/:attachment/:id/:basename.:extension"

  before_save :body_to_html
  before_document_post_process :image?

  attr_accessible         :news_date, :title, :summary, :headline, :body, :url, :document
#  attr_accessible         :news_date, :headline, :body, :url, :document
#  validates_presence_of   :news_date, :headline, :body, :news_category, :news_provider
#
#  validates_length_of     :headline,  :in => 2..250
#  validates_length_of     :body,      :in => 2..65000
  #  validates_length_of     :url,       :in => 2..250,    :allow_blank => false
  #
  #  validates_attachment_presence     :document
  #  validates_attachment_size         :document, :less_than => 1.megabytes
  #  validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  #  validate :must_belong_to_category, :must_belong_to_provider

  def body_to_html
    self.body = self.body.gsub("\n", '<br />')
  end

  def image?
    !(document_content_type =~ /^image.*/).nil?
  end

#  def NewsItem.latest_press_releases(count)
#    ncid = (NewsCategory.find_by_title("Press Releases")).id
#    NewsItem.find(:all, :conditions => ["news_category_id = ?", ncid], :order => "news_date DESC", :limit => count)
#  end
#
  def NewsItem.latest_news_articles(count)
    ncid = (NewsCategory.find_by_title("News Articles")).id
    NewsItem.find(:all, :conditions => ["news_category_id = ?", ncid], :order => "news_date DESC", :limit => count)
  end

  def NewsItem.latest_white_papers(count)
    ncid = (NewsCategory.find_by_title("White Papers")).id
    NewsItem.find(:all, :conditions => ["news_category_id = ?", ncid], :order => "news_date DESC", :limit => count)
  end

#  def title
#    self.headline.slice(0, @@title_length)
#  end
#
#  # Gets Short Summary for the description
#  # TODO modify slicing so to incorporate word boundry
#  def news_summary
#    self.body.slice(0, @@summary_length)
#  end
  require 'rss/2.0'
  require 'open-uri'


    def self.parseFeed (url, length)
      feed_url = url
      output = "";
      open(feed_url) do |http|
        response = http.read
        result = RSS::Parser.parse(response, false)
        output = "<span class=\"feedTitle\">#{result.channel.title}</span><br /><strong>"
        result.items.each_with_index do |item, i|
          output += "<a href=\"#{item.link}\">#{item.title}</a><br/>" if ++i < length
        end
        output += "</strong><br/>"
      end
      return output
    end

#  define_index do
#    indexes title
#    indexes headline
#    indexes body
#    indexes summary
#    indexes user_id
#    set_property :delta => true
#  end

  def description
    return summary
  end
end
