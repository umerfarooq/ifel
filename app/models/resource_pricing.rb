class ResourcePricing < ActiveRecord::Base
  belongs_to :resource
  belongs_to :pricing
end
