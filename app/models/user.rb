class User < ActiveRecord::Base
  acts_as_follower

  belongs_to :user_type
  has_one    :company
  has_one :credential
  has_one :project
  belongs_to :promo_code
  belongs_to :industry
  has_many :messages, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :transaction_logs, :dependent => :destroy
  has_many :community_question, :dependent => :destroy
  has_many :community_answer, :dependent => :destroy
  has_many :topic, :dependent => :destroy
  has_many :replies, :through => :messages, :source => :comments, :dependent => :destroy
  has_many :subject_followings, :dependent => :destroy
  belongs_to :mentor
  belongs_to :registration_code
  
  serialize :experted_sections

  named_scope :community_experts_with_comments,:select => "users.*", :joins => "LEFT JOIN comments ON users.id = comments.user_id", :conditions => {:is_community_expert => true}, :group => "users.id", :order => "COUNT(users.id) DESC"
  named_scope :community_experts, :conditions => {:is_community_expert => true}
  named_scope :without_mentor, :conditions => {:mentor_id => nil}
  named_scope :without_industry, :conditions => {:industry_id => nil}
  named_scope :name_wise, {:order => "first_name ASC"}
  named_scope :first_name_wise, lambda { |sort| {:order => "first_name #{sort}"}}
  named_scope :industry_wise, lambda { |sort| {:include => :industry, :order => "industries.title #{sort}"}}
  named_scope :business_idea_wise, lambda { |sort| {:order => "business_idea #{sort}"}}
  
  named_scope :only, lambda{ |number| {:limit => number} }
  named_scope :with_industries, lambda{ |industries| {:select => "id, first_name, last_name, business_idea, industry_id",:conditions => ['industry_id IN(?)',industries ]} }

  accepts_nested_attributes_for :credential, :allow_destroy => :true  ,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :project, :allow_destroy => true

  #validate :varify_old_password
  acts_as_authentic do |c|
    c.logged_in_timeout(60.minutes)
    #c.validate_login_field(false)
    c.validates_format_of_login_field_options({:with => /^[a-zA-Z0-9._-]+$/, :message => 'must contain only alphnumeric characters, periods, under-scores or hiphens'})
  end

  has_attached_file :profile_picture,
    :styles => { :normal => "100x100!", :thumbnail => "30x30!", :profile => "25x25!", :grid_view => "25x25!" },
    :url => "/client/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/client/:class/:attachment/:id/:style/:basename.:extension"

  validates_attachment_size         :profile_picture, :less_than => 10.megabytes, :if => Proc.new { |record| !record.profile_picture_file_name.blank? }
  #validates_attachment_content_type :profile_picture, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.profile_picture_file_name.blank? }

  validate_on_create :validate_startup_process_date, :validate_wibo_affiliation
  validates_associated :project
#  validates_presence_of :nyu_affiliation, :message => "Wibo affiliation can't be blank", :unless => Proc.new { |user| user.associated_with_ifel }
  validates_presence_of :first_name, :last_name, :login#, :screen_name
  validates_presence_of :startup_process_start_date, :business_idea, :signup_code, :on => :create
  validate_on_create :validate_signup_code
  validates_presence_of :startup_process_start_date, :business_idea, :on => :update
  validates_length_of :business_idea, :maximum => 50
  validates_format_of :business_idea, :with => /^[a-zA-Z0-9_,.'";:()$&#\@!%?\-\/\\ ]+$/, :message => 'must contain only alphnumeric characters, spaces, and _,-.\'()";:$&#@!%/?\\', :unless => Proc.new { |record| record.business_idea.blank? }
  
  validates_numericality_of :contact_number, :allow_blank => true
  validates_presence_of :password, :if=>:password_required?
  validates_presence_of :password_confirmation, :if=>:password_required?
  #  validates_presence_of :other_industry, :if => :other_industry_required?, :on => :create

  validates_confirmation_of :email, :message => "should match confirmation"
  validates_acceptance_of :terms_of_service,  :on => :create, :allow_nil => false

  validates_length_of :first_name,    :maximum => 50
  validates_length_of :last_name,     :maximum => 50
#  validates_length_of :screen_name,   :maximum => 50

  #  validates_format_of :first_name,    :with => /^[a-zA-Z-]+$/, :message => 'must contain only alphabets or hiphens', :unless => Proc.new { |record| record.first_name.blank? }
  #  validates_format_of :last_name,     :with => /^[a-zA-Z-]+$/, :message => 'must contain only alphabets or hiphens', :unless => Proc.new { |record| record.last_name.blank? }
  #validates_format_of :login,   :with => /^[a-zA-Z0-9._-]+$/, :message => 'should use only letters, numbers, spaces'#, :unless => Proc.new { |record| record.login.blank? }
  #  validates_format_of :login,   :with => /^[a-zA-Z0-9._-]+$/, :message => 'must contain only alphnumeric characters, periods, under-scores or hiphens', :unless => Proc.new { |record| record.login.blank? }
#  validates_format_of :screen_name,   :with => /^[a-zA-Z0-9._-]+$/, :message => 'must contain only alphnumeric characters, periods, under-scores or hiphens', :unless => Proc.new { |record| record.screen_name.blank? }
  #  validates_format_of :gender,        :with => /^m|f$/, :message => 'must be male(m) or female(f)'
  #  validates_format_of :is_first_time, :with => /^y|n$/, :message => 'must be yes(y) or no(n)'

  before_create           :set_creation_defaults  
  after_create :create_user_project, :create_forum_user
  after_save              :clear_passwords
  after_update :set_mentor_assignment_date
  

  #  attr_accessible :first_name, :last_name, :screen_name, :gender, :is_first_time, :password, :password_confirmation,:old_password,:project_attributes, :industry_id, :email_confirmation, :email, :login, :terms_of_service, :business_name, :startup_process_start_date, :planning_days
  attr_accessor :old_password ,:other_industry, :plain_password

  named_scope :with_role, lambda { |role| { :conditions => {:role => role} } }

  def role?(rol)
    self.role == rol.to_s
  end

  # return false if not matched
  def varify_old_password
    digest = "#{old_password}#{password_salt}"
    20.times { digest = Digest::SHA512.hexdigest(digest) }
    self.errors.add(:old_password," not varified")
    return digest==crypted_password
  end

  def validate_startup_process_date
    self.errors.add(:startup_process_start_date, "should not be in past") if self.startup_process_start_date < Date.today
  end
  
  def validate_wibo_affiliation
    self.errors.add_to_base("Wibo affiliation can't be blank") unless self.associated_with_ifel
  end

  def blocked?
    self.is_blocked == true
  end
  
  def has_mentor?
    self.mentor.present?
  end

  def deliver_password_reset_email!
    reset_perishable_token!
    UserMailer.deliver_password_reset_email(self)
  end

  def deliver_confirmation_email
    #    reset_perishable_token!
    UserMailer.deliver_confirmation_email(self)
  end


  def deliver_billing_email
    #    reset_perishable_token!
    UserMailer.deliver_billing_email(self)
  end

  # TODO [8/30/10 5:50 PM] => MOVED_TO_COMMENTS_MODEL
  #  def deliver_reply_to_message_email(comment)
  #    unless comment.user == self
  #      UserMailer.deliver_reply_to_message_email(comment.user, self, comment.message, comment)
  #    end
  #  end

  def deliver_alert_email(user, section)
    UserMailer.deliver_alert_email(user, section)
  end

  def deliver_warning_email
    #    reset_perishable_token!
    UserMailer.deliver_warning_email(self)
  end

  def deliver_block_account_email
    #    reset_perishable_token!
    UserMailer.deliver_block_account_email(self)
  end

  def deliver_charge_successful_email
    #    reset_perishable_token!
    UserMailer.deliver_charge_successful_email(self)
  end

  def deliver_leave_account_email
    #    reset_perishable_token!
    UserMailer.deliver_leave_account_email(self)
  end

  def deliver_check_in_email_third_day
    UserMailer.deliver_check_in_email_third_day(self)
  end

  def deliver_check_in_email_fifth_day
    UserMailer.deliver_check_in_email_fifth_day(self)
  end

  def clear_passwords
    self.password = nil
    self.password_confirmation = nil
  end

  def is_admin?
    self.user_type == UserType.find_by_title('admin')
  end

  def new_message_count
    s = 0
    self.messages.each do |msg|
      s += msg.comments.find_all_by_is_appropriate_and_is_new(true, true).size
    end
    s
  end

  def business_name
    ( self.project ) ? self.project.business_name : ""
  end

  def business_name=(value)
    if( self.project )
      self.project.business_name = value
    else
      RAILS_DEFAULT_LOGGER.debug "__User__TODO__business_name=(#{value})__TODO__User__"
    end
  end

  #  def industry_id
  #    ( self.project ) ? self.project.industry_id : ""
  #  end
  #
  #  def industry_id=(value)
  #    if( self.project )
  #      self.project.industry_id = value
  #    else
  #      RAILS_DEFAULT_LOGGER.debug "__User__TODO__industry_id=(#{value})__TODO__User__"
  #    end
  #  end

  def password_required?
    self.crypted_password.blank? || !old_password.blank?
  end

  def other_industry_required?
    Industry.is_other_industry?(self.industry_id) unless self.industry_id.blank?
  end

  def name
    "#{self.last_name}, #{self.first_name}"
  end

  def self.search(options)
    query = options[SEARCH_FIELD.to_sym].strip
    return User.find(:all, :conditions => ["first_name LIKE(?) OR last_name LIKE(?) OR screen_name LIKE(?)","%#{query.to_s}%", "%#{query.to_s}%", "%#{query.to_s}%"])
  end

  def is_employee?
    self.role == 'employee'
  end

  def is_community_expert?
    self.is_community_expert
  end

  def mark_as_employee(can_mark=true)
    if can_mark
      self.update_attribute(:role, 'employee')
    else
      self.update_attribute(:role, 'customer')
    end    
  end

  def unmark_as_expert
    #    mark = (options[:mark_as_expert].to_s == 'true') ? true : false
    #    section = (options[:experted_section].to_i == 0) ? nil : options[:experted_section].to_i
    self.update_attributes({:is_community_expert => false, :experted_sections => nil})
  end

  def is_logged_in_for_the_first_time?
    self.login_count <= 1
  end

  def fix_user_project
    self.create_user_project
  end
  
  #Second Day Email altered to be send over after 72-Hours of registration
  def self.send_second_day_email
    users = User.find(:all,
      :select=>"email,first_name,last_name",
      :conditions=>["DATE(users.registration_date) =?",Date.parse(3.days.ago.to_s)])
    users.each do |user|
      AdminMailer.deliver_second_day_email(user)
    end
  end
  def self.send_daily_signup_report
    file_name = "daily_registration_#{1.day.ago.to_date.to_s}_12:00AM-11:59PM.xlsx"
    file_path = Rails.root.join("temp", "reports", file_name)
    User.cron_registration_report(file_path)
    #    send(file_path)
    #    AdminMailer.deliver_send_daily_signup_report(file_path, file_name)
  end
  
  def self.send_message_email_to_community_expert(options)
    User.experts_in_community.each do|user|
      if user.experted_sections
        if user.experted_sections.include?(options[:section_id].to_s)
          options[:user] = user
          AdminMailer.deliver_message_email_to_community_expert(options)
        end  
      end
      
    end
  end
  
  def self.experts_in_community
    User.find(:all, :select => "first_name, last_name, email, experted_sections", :conditions=>["is_community_expert =?", true])
  end
  
  def notify_mentor_assignment(mentor)
    AdminMailer.deliver_notify_mentor_assignment_to_user(mentor, self)
  end
  
  def email_mentor(content)
    content[:user] = self
    UserMailer.deliver_email_to_mentor content
    return true
  end
  
  def self.test_email
    AdminMailer.deliver_test_email
  end
  
  protected
  def set_creation_defaults
    self.user_type = UserType.find_by_title("registered")
    self.screen_name = self.login
    self.role = "customer"
    time_by_est = (Time.zone.now - 5.hours)
    self.registration_date = time_by_est
    self.login_expiry_date = time_by_est + 1.year
    self.password_modified_date = time_by_est    
    self.planning_days = nil
    self.startup_process_end_date = nil
  end

  def create_user_project
    project = Project.new({:business_name => self.business_idea, :start_date => self.startup_process_start_date, :max_days => self.planning_days.to_i })
    project.user = self
    project.save
  end
  def self.cron_registration_report(file_path)
    FileUtils.mkdir_p(file_path.dirname) unless File.directory?(file_path.dirname)
    users = User.find(:all,:conditions=>['Date(registration_date)=?',Date.parse(1.day.ago.to_s)])
    SimpleXlsx::Serializer.new(file_path) do |doc|
      doc.add_sheet("Registered User Report") do |sheet|
        sheet.add_row(["Reporting Period From:",'','',"#{(Date.today-1.day).strftime("%d %B, %Y")}","12:00AM","","#{(Date.today-1.day).strftime("%d %B, %Y")}","11:59PM"])
        sheet.add_row(['ID','FirstName', 'LastName', 'Email', 'Contact Number', 'Academic Status', 'Source of Information', 'NYU Affiliation', 'Package_Name', 'FirstTime', 'BusinessName', 'Industry', 'UserName' ,'Registration_Date', 'Is_Blocked', 'Cancellation_Date', 'ReactivationDate', 'TotalPaid', 'Last_Logged_In_At'])
        users.each do |user|
          sheet.add_row([user.id,
              user.first_name,
              user.last_name,
              user.email,
              user.contact_number,
              user.academic_status,
              user.source,
              user.nyu_affiliation,
              user.promo_code.code,
              user.is_first_time,
              user.business_name,
              (user.industry)?user.industry.title : '',
              user.login,
              user.registration_date.to_date,
              user.is_blocked,
              user.expire_date,
              user.reactivation_date,
              user.amount_paid,
              (user.current_login_at.to_date rescue '')
            ])
        end
      end
    end unless File.file?(file_path)
  end
  
  def set_mentor_assignment_date
    if self.mentor_id_changed?
      unless self.mentor_id.blank?
        if self.mentor_assignment_date.blank?
          self.update_attribute(:mentor_assignment_date, DateTime.now)
        end        
      else
        self.update_attribute(:mentor_assignment_date, nil ) unless self.mentor_assignment_date.blank?
      end
    end
  end
  
  def create_forum_user
    forum_user = ForumAccount.new
    forum_user.register_user({:username=>self.login, :password=>self.password, :email=>self.email})
  end
  
  def validate_signup_code
    if self.signup_code.present?
      self.errors.add(:signup_code, "is not Valid") unless RegistrationCode.is_valid_code? self.signup_code
    end    
  end
  
end

# app/models/forum.rb
class Forum < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "forum_#{Rails.env.to_s}"
end

# app/models/forum_account.rb
class ForumAccount < Forum
  set_table_name :forum_users # add the table prefix if you set one in punBB

  def encrypt_and_save_new_password(_password)
    write_attribute("password", forum_hash(_password) )
    save
  end
  
  def register_user(options)
    self.username = options[:username]
    self.salt = ActiveSupport::SecureRandom.base64(12)
    self.password = forum_hash(options[:password])
    self.email = options[:email]
    self.save!
  end
 
  private
  def forum_hash( _str )
    Digest::SHA1.hexdigest( self.salt + Digest::SHA1.hexdigest( _str ) )
  end

end