require 'rss'
class BlogFeed < ActiveRecord::Base
  
  def self.update_recent_blog_feed    
    all_blogs_feeds = []
    recent_post_per_blog = {}
    if SITE_BASIC_AUTH_ENABLED
      SITE_BLOGS_LINKS.each_with_index do |site_blog, index|
        all_blogs_feeds = RSS::Parser.parse(open(site_blog, :http_basic_authentication => [SITE_BASIC_AUTH_USER, SITE_BASIC_AUTH_PASS]).read, false).items
        recent_post_per_blog[SITE_BLOGS[index]] = all_blogs_feeds.sort_by { |a| a.pubDate.to_datetime }.last      
      end
    else
      SITE_BLOGS_LINKS.each_with_index do |site_blog, index|
        all_blogs_feeds = RSS::Parser.parse(open(site_blog).read, false).items
        recent_post_per_blog[SITE_BLOGS[index]] = all_blogs_feeds.sort_by { |a| a.pubDate.to_datetime }.last         
      end
    end
    most_recent_date = recent_post_per_blog[SITE_BLOGS[0]].pubDate.to_datetime
    most_recent_post = recent_post_per_blog[SITE_BLOGS[0]]
    most_recent_blog = SITE_BLOGS[0]
    blog_url = SITE_BLOGS_TITLES[0]
    
    recent_post_per_blog.each_with_index do |key, index|
      if recent_post_per_blog[SITE_BLOGS[index]].pubDate.to_datetime > most_recent_date
        most_recent_date = recent_post_per_blog[SITE_BLOGS[index]].pubDate.to_datetime
        most_recent_post = recent_post_per_blog[SITE_BLOGS[index]]
        most_recent_blog = SITE_BLOGS[index]
        blog_url = SITE_BLOGS_TITLES[index]
      end
    end
    update_entry(most_recent_post, most_recent_blog, blog_url)
  end
  private
  def self.update_entry(post, blog, blog_url)
    entry = BlogFeed.first
    if entry
      entry.update_attributes(
        :title=> post.title.to_s,
        :description => post.description.to_s,
        #      :description=> post.content.to_s,
        :link=> post.link.to_s,
        :published_at=> post.pubDate.to_datetime,
        :guid=> post.guid,
        :blog_type=> blog,
        :blog_url => blog_url
      )
    else
      create!(
        :title=> post.title.to_s,
        :description => post.description.to_s,
        #      :description=> post.content.to_s,
        :link=> post.link.to_s,
        :published_at=> post.pubDate.to_datetime,
        :guid=> post.guid,
        :blog_type=> blog,
        :blog_url => blog_url
      ) 
    end
  end
end
