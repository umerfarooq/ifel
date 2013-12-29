class UserType < ActiveRecord::Base
  has_many :users, :dependent => :destroy


  def self.get_registered_type
    find_by_title("registered").id
  end
  
end
