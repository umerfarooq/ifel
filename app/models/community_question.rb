class CommunityQuestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :section
  has_many :community_answer, :dependent => :destroy
end
