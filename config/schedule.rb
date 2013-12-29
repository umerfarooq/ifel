# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#every 1.day, :at => '1:45pm' do
#  rake "touchpoint:set_all"
#end
#
#every 1.day, :at => '2pm' do
#  rake "touchpoint:run_all"
#end
#
#every 1.day, :at => '1:45am' do
#  rake "touchpoint:set_all"
#end
#
#every 1.day, :at => '2am' do
#  rake "touchpoint:run_all"
#end

every 1.day, :at => '12am' do
  rake "event:pull_feeds"
  rake "news:pull_feeds"
end

#every 1.day, :at => '9am' do
#  rake "email:signups_report"
#end

#every 1.day, :at => '11pm' do
#  rake "email:second_day_of_registration"
#end
#
#every :hour do
#  runner "BlogFeed.update_recent_blog_feed"
#end
