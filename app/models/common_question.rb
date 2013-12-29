class CommonQuestion < ActiveRecord::Base
  acts_as_tree

  belongs_to :section_template
  belongs_to :state

  named_scope :get_parents, :conditions => {:parent_id => nil}
  named_scope :children, :conditions => ["parent_id IS NOT NULL"]
  named_scope :are_not_leaves, :conditions => {:level => 1}
  named_scope :published, :conditions => {:state_id => State.published.id}
  named_scope :sequence_wise, :order => 'sequence_number ASC'

  validates_uniqueness_of :section_template_id, :allow_nil => true
  validates_presence_of :statement
  validates_presence_of :section_template_id, :if => proc { |obj| obj.parent_id.nil? }
  validates_length_of :description, :within => 0..600, :allow_nil => true
  validates_presence_of :button_url, :unless => proc { |obj| obj.button_text.blank? }#:if => :is_button_text_set

  has_attached_file :video,
    :url => "/admin/:class/:attachment/:id/:basename.:extension",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:basename.:extension"

  has_attached_file :photo, :styles => { :normal => "310x175!" },
    :url => "/admin/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/admin/:class/:attachment/missing_:style.png",
    :path => ":rails_root/public/admin/:class/:attachment/:id/:style/:basename.:extension"

  validates_attachment_size         :photo, :less_than => 10.megabytes, :if => Proc.new { |record| !record.photo_file_name.blank? }
  validates_attachment_content_type :photo, :content_type => FILE_TYPE_IMAGE, :if => Proc.new { |record| !record.photo_file_name.blank? }
  validates_attachment_size         :video, :less_than => 100.megabytes, :if => Proc.new { |record| !record.video_file_name.blank? }

  attr_accessor :panel_id

  before_create :set_creation_defaults
  before_save :set_level, :url_absolutify

  def set_creation_defaults
    if CommonQuestion.all.blank?
      self.sequence_number = 1
    else
      if self.parent.blank?
        self.sequence_number = (CommonQuestion.roots.last.sequence_number + 1)
      else
        if self.parent.children.count == 0
          self.sequence_number = 1
        else
          self.sequence_number = (self.parent.children.last.sequence_number + 1)
        end
      end
    end
    self.state = State.inactivated
  end

  def set_level
    if self.parent.nil?
      self.level = 0
    elsif self.parent.parent.nil?
      self.level = 1
    else
      self.level = 2
    end
  end

  def url_absolutify
    unless self.button_url.blank?
      unless self.button_url[0..3] == "http"
        self.button_url = 'http://'.concat(self.button_url.to_s)
      end
    end
  end

  def at_root_level?
    self.level == 0
  end

  def at_first_level?
    self.level == 1
  end

  def at_second_level?
    self.level == 2
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

  def on_top?
    if self.parent_id.blank?
      self.sequence_number == CommonQuestion.minimum(:sequence_number)
    else
      self.sequence_number == self.parent.children.minimum(:sequence_number)
    end
  end

  def on_bottom?
    if self.parent_id.blank?
      self.sequence_number == CommonQuestion.maximum(:sequence_number)
    else
      self.sequence_number == self.parent.children.maximum(:sequence_number)
    end
  end

  def move_up
    if self.parent.blank?
      #If anywhere down the Top most element
      if self.sequence_number > CommonQuestion.get_parents.minimum(:sequence_number)
        #Sequentially immediate Up node of Current node
        immediate_up_node = CommonQuestion.get_parents.find(:last, :conditions=>['sequence_number < ?',self.sequence_number])
        immediate_up_node_sequence_no = immediate_up_node.sequence_number
        # Swap the Sequential Order
        immediate_up_node.update_attribute(:sequence_number,self.sequence_number)
        self.update_attribute(:sequence_number,immediate_up_node_sequence_no)
        return true
      else
        return false
      end
    else
      #If anywhere down the Top most element
      if self.sequence_number > self.parent.children.minimum(:sequence_number)
        #Sequentially immediate Up node of Current node
        immediate_up_node = CommonQuestion.find(:last,:conditions=>['parent_id = ? AND sequence_number < ?',self.parent_id,self.sequence_number])
        immediate_up_node_sequence_no = immediate_up_node.sequence_number
        # Swap the Sequential Order
        immediate_up_node.update_attribute(:sequence_number,self.sequence_number)
        self.update_attribute(:sequence_number,immediate_up_node_sequence_no)
        return true
      else
        return false
      end
    end
  end

  def move_down
    if self.parent.blank?
      if self.sequence_number < CommonQuestion.get_parents.maximum(:sequence_number)
        #Sequentially immediate Down node of Current node
        immediate_down_node = CommonQuestion.get_parents.find(:last, :conditions=>['sequence_number > ?',self.sequence_number])
        immediate_down_node_sequence_no = immediate_down_node.sequence_number
        # Swap the Sequential Order
        immediate_down_node.update_attribute(:sequence_number,self.sequence_number)
        self.update_attribute(:sequence_number,immediate_down_node_sequence_no)
        return true
      else
        return false
      end
    else
      if self.sequence_number < self.parent.children.maximum(:sequence_number)
        #Sequentially immediate Down node of Current node
        immediate_down_node = CommonQuestion.find(:last, :conditions=>['parent_id = ? AND sequence_number > ?',self.parent_id,self.sequence_number])
        immediate_down_node_sequence_no = immediate_down_node.sequence_number
        # Swap the Sequential Order
        immediate_down_node.update_attribute(:sequence_number,self.sequence_number)
        self.update_attribute(:sequence_number,immediate_down_node_sequence_no)
        return true
      else
        return false
      end
    end
  end

  def url_for_video_player
    if VIDEOS_ON_S3
      "http://wickedstartbucket.s3.amazonaws.com#{self.video.url(nil, false)}"
    else
      self.video.url(nil, false)
    end
  end

  def deliver_have_a_question_email(question)
    puts("----------------------------#{question.to_s}---------------------------------------------")
    AdminMailer.deliver_have_a_question_email(question)
  end
end