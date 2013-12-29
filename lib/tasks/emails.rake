namespace :email do
  desc "Send Welcome Email Again on Second Day of Registration"
  task :second_day_of_registration => :environment do
    User.send_second_day_email
  end

  desc "Send Daily Signups Report"
  task :signups_report => :environment do
    User.send_daily_signup_report
  end
end
