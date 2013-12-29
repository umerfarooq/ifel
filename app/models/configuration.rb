class Configuration < ActiveRecord::Base
  
  has_attached_file :logo, :styles => { :header => "345x134#" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"



  
end
