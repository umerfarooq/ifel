class NewsCategory < ActiveRecord::Base
  has_many :news_items, :dependent => :destroy
  belongs_to :state
end
