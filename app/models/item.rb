class Item < ActiveRecord::Base
  belongs_to :section
  belongs_to :item_template
  #  has_many :documents
  has_many :documents, :as => :documentable, :dependent => :destroy
  has_many :notes, :dependent => :destroy

  #  attr_readonly :section_id, :item_number, :sequence_number, :title, :definition, :description, :percent, :has_textbox, :has_upload, :is_example_simple, :example_description
  #  attr_accessible :answer, :is_complete, :is_applicable

  after_save :update_completed_count
  
  named_scope :ended, :conditions => ["is_complete = ? OR is_applicable = ?", true, false]
  named_scope :are_applicable, :conditions => {:is_applicable => true}
  named_scope :completed, :conditions => {:is_complete => true}
  named_scope :are_not_complete, :conditions => {:is_complete => false}
  named_scope :are_in_progress, :conditions => {:is_viewed => true}, :order => "updated_at DESC"
  named_scope :sequence_wise, :order => "sequence_number ASC"
  named_scope :only,lambda {|number| {:limit => number}}


  # TODO [11/9/10 12:18 AM] => VALIDATIONS
  # ADD_VALIDATIONS_FOR_DOCUMENTS
  # ADD_VALIDATIONS_FOR_SECTION_AND_ITEM_TEMPLATE_IF_NECESSARY

  #  def Item.all_active
  #    Item.find_all_by_is_active(true)
  #  end

  def update_completed_count
    self.section.update_completed_count
  end

  def reviewed!
    self.update_attribute("is_viewed", true) unless self.is_viewed
    self.section.project.update_attribute(:open_section, self.section_id)
  end

  def edited?
    (!self.user_answer.blank?)||(!self.documents.blank?)||(!self.notes.blank?)
  end

  def completed?
    self.is_complete
  end

  def inprogress?
    !self.completed? and self.is_viewed?
  end

  def aplicable?
    self.is_applicable
  end

  def ended?
    self.is_complete || self.is_not_applicable
  end

  def is_not_applicable
    self.is_applicable == false
  end

  def is_not_applicable=(value)
    self.is_applicable = (value == false)
    self.save
  end

  def is_not_viewed?
    self.is_viewed == false
  end

  def is_viewed?
    self.is_viewed == true
  end

  def preceding
    if self.sequence_number == self.section.items.minimum(:sequence_number)
      #      puts "a"
      self.section
    else
      #      puts "b"
      #      Item.find_by_sequence_number self.section.items.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      self.section.items.find_by_sequence_number self.section.items.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
    end
  end

  def following
    if self.sequence_number == self.section.items.maximum(:sequence_number)
      if self.section.sequence_number == self.section.project.sections.maximum(:sequence_number)
        #        puts "a.a"
        #        Section.find_by_sequence_number self.section.project.sections.minimum(:sequence_number)
        self.section.project.sections.find_by_sequence_number self.section.project.sections.minimum(:sequence_number)
      else
        #        puts "a.b"
        #        Section.find_by_sequence_number self.section.project.sections.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.section.sequence_number])
        self.section.project.sections.find_by_sequence_number self.section.project.sections.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.section.sequence_number])
      end
    else
      #      puts "b"
      #      Item.find_by_sequence_number self.section.items.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      self.section.items.find_by_sequence_number self.section.items.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
    end
  end

  def is_first_in_the_project?
    if self.section.eql?(self.section.project.sections.sequence_wise.first)
      return self.eql?(self.section.items.sequence_wise.first)
    end
    false
  end
  
  def is_last_in_the_project?
    if self.section.eql?(self.section.project.sections.sequence_wise.last)
      return self.eql?(self.section.items.sequence_wise.last)
    end
    false
  end

  def successor
    successor = nil
    unless self.is_last_in_the_project?
      section_items = self.section.items.sequence_wise
      unless self.eql?(section_items.last)
        section_items.each { |i| (break successor=i) if i.sequence_number > self.sequence_number }
      else
        next_section = nil
        self.section.project.sections.sequence_wise.each { |s| (break next_section=s) if s.sequence_number > self.section.sequence_number }
        successor = next_section.items.sequence_wise.first
      end
    end
    successor
  end


  def predecessor
    predecessor = nil
    unless self.is_first_in_the_project?
      section_items = self.section.items.sequence_wise
      unless self.eql?(section_items.first)
        section_items.reverse_each { |i| (break predecessor=i) if i.sequence_number < self.sequence_number }
      else
        prev_section = nil
        self.section.project.sections.sequence_wise.reverse_each { |s| (break prev_section=s) if s.sequence_number < self.section.sequence_number }
        predecessor = prev_section.items.sequence_wise.last
      end
    end
    predecessor
  end

  # update_attributes should be used, but it isn't working perfectly for some weired reason :(
  def mark_as_complete(options)
    self.is_complete = options[:is_complete]
    self.is_applicable = true # if item.is_complete
    self.save_with_validation(false)
  end

  def mark_as_not_applicable(options)
    self.is_applicable = options[:is_applicable]
    self.is_complete = false if self.is_not_applicable
    self.save_with_validation(false)
  end


  define_index do
    #indexes title
    indexes section.project.user(:id), :as => :user_id
    #indexes item.item_template.definition, :as => :dscrption
    set_property :delta => true
    #    has "section.project.user.id == 2", :type=>:integer, :as=>:is_private
  end

  def description
    return self.item_template.definition
  end

end
