class Comment < ActiveRecord::Base
  acts_as_likeable
  
  belongs_to :message
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :inappropriates, :as => :appropriable

  has_many :comment_ratings
  has_many :raters, :through => :comment_ratings, :source => :user

  attr_accessible :body, :is_private

  before_create :set_creation_defaults

#  named_scope :private, lamdba {|user_id|
#  {
#    :joins => "INNER JOIN messages ON comments.message_id = messages.id",
#    :condition => ["(comments.is_private = ? ) AND (messages.user_id = ?)", false, user_id]
#  }
#  }

  named_scope :comment_email_condition, lambda {|user_id|
    {
      :conditions =>["comments.user_id != ?",user_id]
    }
  }
  named_scope :appropriate, :conditions => {:is_appropriate => true}
#  named_scope :for_user, lambda { |user_id|
#    {
#      :joins => "INNER JOIN messages ON comments.commentable_id = messages.id",
#      :conditions => ["(comments.is_private = ?) OR (comments.user_id = ?) OR (messages.user_id = ?) AND comments.commentable_type =?", false, user_id, user_id, 'Message']
#    }
#  }

  named_scope :for_user, lambda { |user_id|
    {
      :joins => "INNER JOIN messages ON comments.message_id = messages.id",
      :conditions => ["(comments.is_private = ?) OR (comments.user_id = ?) OR (messages.user_id = ?) AND comments.commentable_type =?", false, user_id, user_id, 'Message']
    }
  }
  named_scope :for_message, :conditions => { :commentable_type => "Message"}
  named_scope :not_viewed, :conditions => {:is_new => true}

  named_scope :datewise, :order=> "created_at desc"
  named_scope :only,lambda {|number| {:limit => number}}
  named_scope :of_same_message, lambda{|message_id| {:conditions => {:message_id => message_id}}} 
  named_scope :by_other_commenters, lambda {|user_id| {:select=>"DISTINCT(comments.user_id)", :conditions =>["comments.user_id != ?",user_id]}}
  
  validates_presence_of :body

  def deliver_reply_to_message_email
    
    UserMailer.deliver_reply_to_message_email(self.user, self.message.user, self.message, self)
  end

  def self.get_user_messages_unread_comments(user)
#    comments = Array.new
#    user.messages.each do |msg|
#      if !msg.comments.not_viewed.blank?
#      comments << msg.comments.not_viewed
#      end
#    end
    Comment.not_viewed.find(:all, :joins=>:message, :conditions=>['messages.user_id=?',user.id] )
    
  end

  def deliver_comment_email_in_model
    comments = Comment.comment_email_condition(self.user_id).find_all_by_message_id(self.message_id)
    comments.each do |comment|
      UserMailer.deliver_comment_email(comment.user, self)
    end
  end
  
  def deliver_comment_email
    comments = Comment.of_same_message(self.message_id).by_other_commenters(self.user_id)
    unless comments.blank?
      comments.each do |comment|
        UserMailer.deliver_comment_on_message_email(comment.user, self, self.message)
      end
    else
      unless self.commenter_is_message_owner?
        UserMailer.deliver_comment_on_message_email(self.message.user, self, self.message)
      end
    end
  end
  
  def commenter_is_message_owner?
    self.user_id == self.message.user_id
  end

  def any_recent_comment_of_user(user)
    return Comment.find_by_user_id(user.id, :order=>"created_at desc")
  end
  def rated_by?(someone)
    CommentRating.find_by_comment_id_and_user_id(self, someone).blank? == false
  end

  def rated_positively_by?(someone)
    if CommentRating.find_by_comment_id_and_user_id(self, someone).blank?
      return false
    else
      return CommentRating.find_by_comment_id_and_user_id(self, someone).is_positive
    end
  end

  def rate_positively_by(someone, is_positive)
    return false unless CommentRating.find_by_comment_id_and_user_id(self, someone).blank?
    comment_rating = CommentRating.new(:is_positive => is_positive)
    comment_rating.user = someone
    comment_rating.comment = self
    if(comment_rating.save)
      if is_positive
        update_attribute(:thumbs_up, thumbs_up + 1)
      else
        update_attribute(:thumbs_down, thumbs_down + 1)
      end
      update_attribute(:rating, thumbs_up - thumbs_down)
    end
  end

  def self.get_comment_count_on_messages(msg, current_user)
    comments = Comment.for_user(current_user).find_all_by_message_id(msg.id)
    return comments.count
  end

    def self.recent_comment_of_message(message)
      comment = Comment.find_all_by_message_id(message.id, :order=> "created_at desc", :limit => 1)
      return comment.first
    end

  #  def current_rating
  #    CommentRating.sum("rate", :conditions => ['comment_id = ?', self])
  #  end

  def unanswered_inappropriate_by?(someone)
    Inappropriate.find_by_appropriable_id_and_appropriable_type_and_user_id_and_is_answered(self, self.class.to_s, someone, false).blank? == false
  end

  def mark_inappropriate_by(someone)
    return false unless Inappropriate.find_by_appropriable_id_and_appropriable_type_and_user_id_and_is_answered(self, self.class.to_s, someone, false).blank?
    inappropriate = Inappropriate.new
    inappropriate.user = someone
    inappropriate.appropriable = self
    inappropriate.is_answered = false
    inappropriate.save
  end

  #  def update_rating
  #    self.rating = CommentRating.sum("rate", :conditions => ['comment_id = ?', self])
  #    self.save
  #  end

  def self.create_comment(params, current_user)
#    comment = Comment.new(params[:comment]) # CANCAN
    comment = Comment.new
    comment.body = params[:body]
    comment.body.gsub!("\r\n","<br />")
    comment.commentable_type = "Message"
    comment.commentable_id = params[:message].to_i
    comment.user = current_user
    comment.is_private = params[:private]
    comment.message = Message.find(params[:message])   # TODO # PROJECT in ROUTES
    if comment.save
      return comment
    end

  end

  
  def viewed!
    self.is_new = false
    self.save
  end

  

  define_index do
    indexes body
    set_property :delta => true
  end

  private
  def set_creation_defaults
    self.is_new = true
    self.is_appropriate = true
    self.thumbs_up = 0
    self.thumbs_down = 0
    self.rating = 0
    self.view_count = 0
  end

end
