class CommunityAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :community_question
end
