class Promotion < ActiveRecord::Base
  set_inheritance_column = 'kind'
  belongs_to :state
  before_create :set_creation_defaults
  before_save :make_valid_url

  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :featured, :conditions => {:state_id => State.featurified.id}
  named_scope :date_wise, :order => 'updated_at DESC'
  named_scope :internal, :conditions => {:is_internal => true}
  named_scope :external, :conditions => {:is_internal => false}
  named_scope :next_promotion,lambda{|current_id| {:conditions => ['id !=? AND state_id =?',current_id,State.published.id] }}
  named_scope :regular_kind_of, :conditions => {:kind => 'RegularPromotion'}
  named_scope :partner_kind_of, :conditions => {:kind => 'PartnerPromotion'}
  named_scope :feature_kind_of, :conditions => {:kind => 'FeaturePromotion'}


  has_attached_file :picture, :styles => { :medium => "300x150>", :small => "300x100>", :large => "300x200>", :quiz => "92x73", :partner => "150x150"},
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png"

  validates_presence_of :head_title
  validates_attachment_presence     :picture
  validates_attachment_size         :picture, :less_than => 10.megabytes, :if => Proc.new { |record| !record.picture_file_name.blank? }
  validates_attachment_content_type :picture, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.picture_file_name.blank? }

  def set_creation_defaults
    self.state = State.inactivated
  end

  def make_valid_url
    unless self.url.blank?
      if !self.url.include?('http://') and !self.url.include?('https://')
        self.url = 'http://'.concat(self.url.to_s)
      end
    end
  end
  
  def internal?
    self.is_internal == true
  end

  def featurified?
    self.state.is_featurified?
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

  def featurify
    if self.state.is_published?
      self.state = State.featurified
      return self.save
    else
      return false
    end
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

  def creation_date
    self.created_at.strftime('%Y-%m-%d')
  end

  def self.size_list
    { 'small (300x100)' => 'small', 'medium (300x150)' => 'medium', 'large (300x200)' => 'large', 'quiz (92x73)' => 'quiz', 'partner (150x150)' => 'partner'}
  end

  def self.factory(options)
    options[:kind].constantize.new(options)
  end

  def self.kind_options
    subclasses.map{ |c| c.to_s }.sort
  end

  def self.reconstruct_promotion_and_get_persisted_kind(options)
    promotion = Promotion.find options[:id]
    original_type = promotion.kind
    promotion.update_attribute(:kind, options[:promotion][:kind])
    return original_type
  end

  def is_regular_promotion?
    self.kind == 'RegularPromotion'
  end

  def is_partner_promotion?
    self.kind == 'PartnerPromotion'
  end
end

class RegularPromotion < Promotion
  validates_presence_of  :url
end

class PartnerPromotion < Promotion
  validates_presence_of  :url
end

class FeaturePromotion < Promotion
  validates_presence_of  :url, :url_text
end


