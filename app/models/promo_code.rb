class PromoCode < ActiveRecord::Base
  has_many :users
  validates_uniqueness_of :code
  validates_presence_of :code, :register_limit, :organization, :status, :registration_fee, :recurring_fee, :month_begins, :day_begins
end
