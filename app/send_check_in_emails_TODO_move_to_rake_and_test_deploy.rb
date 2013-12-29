class SendCheckInEmails < ActiveRecord::Base
#  usr = User.find_by_email('Abdullah.Muhammad@confiz.com')
#  usr.deliver_check_in_email_fifth_day

  users = User.find(:all, :conditions => ["created_at >= ? and created_at < ?", Date.today - 3.day, Date.today - 2.day])
  users.each do |usr|
    puts('m here')
    if usr.is_blocked.nil? || usr.is_blocked == false
      puts('now here')
      if usr.expire_date.nil? || usr.expire_date < Date.today
        puts "#{usr.email} is to be emailed!"
        usr.deliver_check_in_email_third_day
      end
    end
  end

  users = User.find(:all, :conditions => ["created_at >= ? and created_at < ?", Date.today - 5.day, Date.today - 4.day])
  users.each do |usr|
    if usr.is_blocked.nil? || usr.is_blocked == false
      if usr.expire_date.nil? || usr.expire_date < Date.today
        puts "#{usr.email} is to be emailed!"
        usr.deliver_check_in_email_fifth_day
      end
    end
  end


end