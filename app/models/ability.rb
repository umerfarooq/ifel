class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :publish, :activate, :inactivate, :to => :adjust
    alias_action :move_up, :move_down, :to => :jerk

#    user ||= User.new
    if user.blank?
      user = User.new and user.role = "guest"
    end

    if user.role? :super          # The Super User for Development jobs.
      can :manage, :all
    elsif user.role? :owner       # The Owner User for Reports etc.
      can :read, :all
    elsif user.role? :admin       # The Admin User for administrative jobs.
      can :read, :all
#      can [:modify, :list, :adjust, :jerk, :featurify], [SuccessStory]
#      can [:modify, :list, :adjust, :jerk, :flvplayer], Biography
    elsif user.role? :moderator   # The Moderator User to moderate community, etc.
#      can :read, [SuccessStory]
#      can [:index, :flvplayer], Biography
      can [:read, :create, :popular, :for_staff, :report_abuse], Message
      can [:read, :report_abuse, :thumbsup, :thumbsdown], Comment do |comment|
#        comment.blank? || comment.message.is_admin_only || !comment.is_private || comment.message.user_id == user.id || comment.user_id == user.id
        comment.blank? || comment.commentable.is_admin_only || comment.is_private || comment.commentable.user_id == user.id || comment.user_id == user.id
      end
      can :create, Comment
      can :update, [Message, Comment] do |message_or_comment|
        message_or_comment && message_or_comment.user_id == user.id
      end
    elsif user.role? :customer    # The Regular Customer User for using wickedstart.com's paid services.
#      can :read, [SuccessStory]
#      can [:index, :flvplayer], Biography
      can [:create, :popular], Message
      can [:read, :report_abuse], Message do |message|
        message.blank? || !message.is_admin_only || message.user_id == user.id
      end
      can [:read, :report_abuse, :thumbsup, :thumbsdown], Comment do |comment|
        comment.blank? || (!comment.commentable.is_admin_only && !comment.is_private) || comment.commentable.user_id == user.id || comment.user_id == user.id
      end
      can :create, Comment do |comment|
        comment && comment.commentable && (!comment.commentable.is_admin_only || comment.commentable.user_id == user.id)
      end
      can :update, [Message, Comment] do |message_or_comment|
        message_or_comment && message_or_comment.user_id == user.id
      end
    elsif user.role? :banned      # The Banned Regular Customer User that have a suspended account.
      can :read, :all
    elsif user.role? :guest       # The Guest User for accessing wickedstart.com's public pages.
      can [:read], Comment do |comment|
        comment.blank? || (!comment.commentable.is_admin_only && !comment.is_private)
      end
      can [:read], Message do |message|
        message.blank? || !message.is_admin_only
      end
      #      can :read, [SuccessStory]
#      can [:index, :flvplayer], Biography
    else
      RAILS_DEFAULT_LOGGER.info "__ABILITY__CHECK_NO_ROLE__"
    end
  end
end
