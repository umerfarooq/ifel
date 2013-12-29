namespace :event do
  desc "Destroy existing event feeds"
  task :destroy_feeds => :environment do
    RAILS_DEFAULT_LOGGER.info "Destroying event feeds"
    Feed.delete_all("feeder_type='EventsProvider'")
  end
  
  desc "Pull Event Feeds"
  task :pull_feeds => :environment do
    RAILS_DEFAULT_LOGGER.info "Pulling Event Feeds"
    Rake::Task['event:destroy_feeds'].invoke
    feeders = EventsProvider.published
    unless feeders.blank?
      feeders.each do |feeder|
        feeder.update_attribute(:feed_count, 0)
        Feed.update_from_feed(feeder)
      end
    end
  end
end

namespace :news do
  desc "Destroy existing news feeds"
  task :destroy_feeds => :environment do
    RAILS_DEFAULT_LOGGER.info "Destroying news feeds"
    Feed.delete_all("feeder_type='NewsProvider'")
  end

  desc "Pull News Feeds"
  task :pull_feeds => :environment do
    RAILS_DEFAULT_LOGGER.info "Pulling News Feeds"
    Rake::Task['news:destroy_feeds'].invoke
    feeders = NewsProvider.published
    unless feeders.blank?
      feeders.each do |feeder|
        feeder.update_attribute(:feed_count, 0)
        Feed.update_from_feed(feeder) if feeder.rss_link.present?
      end
    end
  end
end