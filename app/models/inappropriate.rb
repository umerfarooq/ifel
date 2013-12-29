class Inappropriate < ActiveRecord::Base

  belongs_to :appropriable, :polymorphic => true
  belongs_to :user

  def suitable
    self.appropriable.is_appropriate
  end
  def suitable=(value)
    self.appropriable.is_appropriate = value
    self.appropriable.save
  end

  def deliver_reply_to_inappropriate_email
    UserMailer.deliver_reply_to_inappropriate_email(self)
  end

end
