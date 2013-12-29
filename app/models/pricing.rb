class Pricing < ActiveRecord::Base

  belongs_to :state
  has_many :resource_pricings
  has_many :resources, :through => :resource_pricings
end
