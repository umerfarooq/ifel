class Mentor < ActiveRecord::Base
  belongs_to :state
  has_many :users
  has_and_belongs_to_many :industries
  
  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :email
  validates_numericality_of :phone_number, :allow_blank => true
  validates_format_of :email,:with => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i
  
  has_attached_file :picture,
    :styles => { :normal => "100x100!", :thumbnail => "30x30!" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/images/no-image.jpg"
  validates_attachment_size         :picture, :less_than => 10.megabytes, :if => Proc.new { |record| !record.picture_file_name.blank? }
  validates_attachment_content_type :picture, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.picture_file_name.blank? }
  
  before_create           :set_creation_defaults
  
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :name_wise, lambda { |sort| {:order => "first_name #{sort}" } }
  
  def name
    "#{self.last_name}, #{self.first_name}"
  end
  
  def published?
    self.state.is_published?
  end

  def activated?
    self.state.is_activated?
  end

  def inactivated?
    self.state.is_inactivated?
  end
  
  def publish
    if self.state.is_activated?
      self.state = State.published
      return self.save
    else
      return false
    end
  end

  def activate
    if self.state.is_inactivated?
      self.state = State.activated
      return self.save
    else
      return false
    end
  end

  def inactivate
    if self.state.is_inactivated?
      return false
    else
      self.state = State.inactivated
      return self.save
    end
  end
  
  #  def notify_mentor_assignment(user)
  #    AdminMailer.deliver_notify_mentor_assignment_to_mentor(self, user)
  #  end
  #  
  def send_notification_emails(user_ids)
    unless user_ids.blank?
      user_ids.each do |id|
        user = User.find(id.to_i)
        AdminMailer.deliver_notify_mentor_assignment_to_mentor(self, user)
        AdminMailer.deliver_notify_mentor_assignment_to_user(self, user)
      end
    end    
  end
  
  private
  
  def set_creation_defaults
    self.state = State.inactivated  
  end
  
end
