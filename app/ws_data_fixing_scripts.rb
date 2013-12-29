require 'htmlentities'
class WsDataFixingScripts < ActiveRecord::Base
  def self.create_users_project
    user=User.find(1958)
    user.fix_user_project
  end
  
  def self.html_decode_resources
    Resource.all.each do |res|
      coder = HTMLEntities.new
      unless res.html_banner.blank?
        res.update_attribute(:html_banner, coder.decode(res.html_banner))
      end
      unless res.html_url.blank?
        res.update_attribute(:html_url, coder.decode(res.html_url))
      end
      unless res.html_image.blank?
        res.update_attribute(:html_image, coder.decode(res.html_image))
      end
    end
  end
end
