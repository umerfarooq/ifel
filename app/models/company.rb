class Company < ActiveRecord::Base
  belongs_to :user
  has_attached_file :logo,
    :styles => { :profile_view => "339x162!" },
    :url => "/client/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/client/:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo_mark,
    :styles => {:profile_view => "118x95!"},
    :url => "/client/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/client/:class/:attachment/:id/:style/:basename.:extension"

  validates_presence_of :short_description
  validates_length_of :short_description,    :maximum => 400
end
