class SubjectFollowing < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :user

  def self.get_topics_followed_by_user(user)
    followed_topics = SubjectFollowing.find_all_by_user_id_and_subject_type(user, "Topic")
    return followed_topics
  end

  def self.get_messages_followed_count(msg)
    followed_messages_count = SubjectFollowing.find_all_by_subject_id_and_subject_type(msg.id, "Message")
    return followed_messages_count.count
  end
end
