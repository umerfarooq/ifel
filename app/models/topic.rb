class Topic < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :user
  has_many :item_templates_topics, :dependent => :destroy
  has_many :item_templates, :through => :item_templates_topics
  has_many :section_templates_topics, :dependent => :destroy
  has_many :section_templates, :through => :section_templates_topics
  belongs_to :state
  has_and_belongs_to_many :messages
  has_many :subject_following, :as => :subject

  before_create :set_creation_defaults

  named_scope :publish, :conditions => {:state_id => 3, :is_orphan=> false}
  named_scope :active, :conditions => {:state_id => 2, :is_orphan=> false}

  def token_inputs
    { :id => id, :name => name }
  end

  def deliver_add_topic_email
    AdminMailer.deliver_add_topic_email(self)
  end

  def self.top_trending
    Topic.find(:all, :select=>['count(*) as number, messages_topics.topic_id'],:joins=>[:messages], :conditions=>["messages.created_at >= DATE_SUB( curdate( ) , INTERVAL 1 MONTH)"], :group=>['messages_topics.topic_id'], :order=>['number DESC'], :limit=>4)
  end

  def is_published?
    self.state == State.published
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
  
  def self.save_or_update_and_associate(options)
    topics = Array.new
    item_templates = Array.new
    section_templates = Array.new
    options[:item_templates].each { |item| item_templates << ItemTemplate.find(item.to_i) } if options[:item_templates].present?
    options[:section_templates].each { |section| section_templates << SectionTemplate.find(section.to_i) } if options[:section_templates].present?
    options[:topics].each { |topic| topics << Topic.find(topic.to_i) } if options[:topics].present?
    
    if options[:association_type]=='new'
      topic = Topic.new({:name=>options[:name], :user_id=>options[:user_id]})
      if topic.save
        topics.push(topic)
      end
    end
       
    unless topics.blank?
      topics.each do|topic|
        topic.item_templates = item_templates if item_templates.present?
        topic.section_templates = section_templates if section_templates.present?
      end      
      return true
    else
      return false
    end
  end

  private
  def set_creation_defaults
    self.state = State.find_by_name('inactivate')
    self.is_orphan = false
    nil
  end
end
