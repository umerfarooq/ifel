class SendAlerts < ActiveRecord::Base

  sections = Section.find(:all, :conditions => ["due_date = ?", Date.today + 1])

  if sections.size > 0
    puts "#{sections.size} persons are to be emailed!"
    sections.each do |section|
      unless section.items_completed_count/section.item_count == 1
        unless section.project.blank?
          unless section.project.user.blank?
            if section.project.user.is_blocked.nil? || section.project.user.is_blocked == false
              if section.project.user.expire_date.nil? || section.project.user.expire_date < Date.today
                puts "#{section.project.user.email} is to be emailed!"
                section.project.user.deliver_alert_email(section.project.user, section)
              end
            end
          end
        end
      end
    end
  end

end
