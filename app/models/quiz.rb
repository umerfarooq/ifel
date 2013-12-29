class Quiz < ActiveRecord::Base
  belongs_to :state
  has_many :questions, :dependent => :destroy
  has_many :quiz_replies, :dependent => :destroy

  attr_accessible :main_title, :sub_title, :main_text, :sub_text, :field_label, :is_point_based, :picture, :email_subject, :email_quiz_name

  named_scope :published, :conditions => { :state_id => State.published }

  has_attached_file :picture, :styles => { :single => "100x100#", :admin => "150x150#" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png"

  validates_uniqueness_of :name
  validates_uniqueness_of :path

  def point_based?
    self.is_point_based
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

end
