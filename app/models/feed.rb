require 'rss' 
class Feed < ActiveRecord::Base
  belongs_to :feeder, :polymorphic => true #Polymorphic association to incorporate other natured feeds in the System
  alias_attribute :event_start_date, :published_at # Temporarily aliased to sort the Events and Feeds as single object
  alias_attribute :event_start_time, :published_at
  named_scope :event_feeds, :conditions => {'feeder_type' => 'EventsProvider'}
  named_scope :news_feeds, :conditions => {'feeder_type' => 'NewsProvider'}
  named_scope :future_feeds, :conditions => ['published_at <?', DateTime.now]
  named_scope :future_event_feeds, :conditions => ['published_at >?', DateTime.now]
  named_scope :date_wise, :order => 'published_at DESC'
  named_scope :sort_wise, :order => 'published_at ASC'
  named_scope :no_of_records, lambda{|number| {:limit=>number}}

  def self.update_from_feed(feeder)    
    feed = RSS::Parser.parse(open(feeder.rss_link).read, false)
    add_entries(feed.items, feeder)
  end
  private
  def self.add_entries(entries, feeder)
    count = 0
    entries.collect do |entry|
      begin
        unless exists? :guid => entry.send(feeder.feed_guid).content # To avoid duplication
          create!(
            :title=> (entry.send(feeder.feed_title).type=='html') ? entry.send(feeder.feed_title).content : entry.send(feeder.feed_title).to_s,
            :summary=> ((entry.send(feeder.feed_summary).type=='html') ? entry.send(feeder.feed_summary).content : entry.send(feeder.feed_summary).to_s unless feeder.feed_summary.blank?),
            :description=> ((entry.send(feeder.feed_description).type=='html') ? entry.send(feeder.feed_description).content : entry.send(feeder.feed_description).to_s unless feeder.feed_description.blank?),
            :link=> (entry.send(feeder.feed_link).type=='text/html') ? entry.send(feeder.feed_link).href : entry.send(feeder.feed_link).to_s,
            :published_at=> DateTime.parse((entry.send(feeder.feed_published_at).type=='html') ? entry.send(feeder.feed_published_at).content.to_s : entry.send(feeder.feed_published_at).to_s),
            :guid=> entry.send(feeder.feed_guid).content,
            :feeder=> feeder
          )
          count += 1
        end
      rescue
        next
      end
    end
    feeder.update_attribute(:feed_count, (feeder.feed_count+count).to_i)
  end


  #
  #This Code Snippet is the FeedZirra implementation, but its not prfectly parsing the Link attribute in and example Feeder: http://www.google.com/calendar/feeds/ldeokg4c61dr9t11plq0od4ad4%40group.calendar.google.com/public/basic
  #

  #  def self.update_from_feed(feeder)
  ##    Feedzirra::Feed.add_common_feed_entry_element('link', {:value => :href, :as => :url, :with => {:type => "text/html"}})
  #    return feed = Feedzirra::Feed.fetch_raw('http://www.google.com/calendar/feeds/ldeokg4c61dr9t11plq0od4ad4%40group.calendar.google.com/public/basic')
  #    if feeder.feed_count == 0
  #      add_entries(feed.entries, feeder)
  #    else
  #      feed = Feedzirra::Feed.update(feed)
  #      add_entries(feed.new_entries) if feed.updated?
  #    end
  #  end
  #  private
  #  def self.add_entries(entries, feeder)
  #    #    begin
  #    count = 0
  #    entries.each do |entry|
  #      begin
  #        unless exists? :guid => entry.send(feeder.feed_guid)
  #          create!(
  #            :title         => entry.send(feeder.feed_title),
  #            :summary      => entry.send(feeder.feed_summary),
  #            :description   => entry.send(feeder.feed_description),
  #            :link          => entry.link,
  #            :published_at => entry.send(feeder.feed_published_at),
  #            :guid         => entry.send(feeder.feed_guid),
  #            :feeder => feeder
  #          )
  #          count += 1
  #        end
  #      rescue
  #        next
  #      end
  #    end
  #    feeder.increment(:feed_count, count)
  #    #    rescue Exception => e
  #    #      RAILS_DEFAULT_LOGGER.info "Exception pulling the Feeds: #{e.message.to_s}"
  #    #    end
  #
  #  end
end
