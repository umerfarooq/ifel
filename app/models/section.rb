class Section < ActiveRecord::Base
  belongs_to :section_template
  belongs_to :project
  has_many :items

  has_many :todos

  has_many :self_documents, :as => :documentable, :class_name => "Document", :order => "updated_at DESC", :dependent => :destroy
  has_many :item_documents, :through => :items, :source => :documents, :order => "updated_at DESC", :dependent => :destroy

#  attr_readonly :name, :sequence_number, :title, :title_comment, :introduction
  named_scope :active, :joins => :section_template, :conditions => { 'section_templates.state_id' => State.published.id }
  named_scope :sequence_wise, :order => 'sequence_number ASC'
  named_scope :due_date_wise, :order => 'due_date ASC'
  named_scope :are_not_in_the_past, :conditions=>['due_date >=?', Date.today]
  named_scope :not_completed, :conditions=>['items_completed_count/item_count != 1']
  #attr_accessor :user_answer

  #  validate hasmany_for_sections_and_projects
  #  def hasmany_for_sections_and_projects
  #    errors.add(:project_id, "must be selected") if project_id.blank?
  #    errors.add(:project_id, "must be a valid value") if !project_id.blank? && Project.find_by_id(project_id).blank?
  #  end

  # TODO [11/3/10 12:57 PM] => get_overview, all_active, active_items ???
  def self.get_overview(id)
    sect = Section.find_by_id(id)
    success = 0
    if sect
      success = 1
    end
    return sect , success
  end

  #  def Section.all_active
  #    Item.find_all_by_is_active(true)
  #  end

  def active_items
    self.items
  end

  def edited?
    (self.user_answer.blank? == false)
  end

  def completed?
    completed = true
    self.items.each do |item|
      completed = false and break if(item.completed? == false)
    end
    return completed
  end


  def ended?
    ended = true
    self.items.each do |item|
      ended = false and break if(item.ended? == false)
    end
    return ended
  end

  def items_completed?(sequence_numbers)
    completed = true
    sequence_numbers.each do |sequence_number|
      item = self.items.find_by_sequence_number(sequence_number)
      completed = false and break if((item.blank?) || (item.completed? == false))
    end
    return completed
  end



  def items_ended?(sequence_numbers)
    ended = true
    sequence_numbers.each do |sequence_number|
      item = self.items.find_by_sequence_number(sequence_number)
      ended = false and break if((item.blank?) || (item.ended? == false))
    end
    return ended
  end

  def completed_items_count
    self.items.find_all_by_is_complete(true).count
  end

  def ended_items_count
    self.items.ended.count
  end

  def do_not_show_intro
    self.do_show_intro == false
  end

  def do_not_show_intro=(value)
    self.do_show_intro = (value == false)
    self.save
  end

  def preceding
    if self.sequence_number == self.project.sections.minimum(:sequence_number)
      # FIRST SECTION should go back to LAST SECTION'S LAST ITEM
      prev_sec = self.project.sections.find_by_sequence_number self.project.sections.maximum(:sequence_number)
    else
      prev_sec = self.project.sections.find_by_sequence_number self.project.sections.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
    end
    prev_sec.items[prev_sec.items.size-1]
  end

  def following
    self.items.find_by_sequence_number self.items.minimum(:sequence_number)
  end

  def update_completed_count
    self.project.update_percentage
    self.items_completed_count = 0
    self.items.each do |item|
      self.items_completed_count += 1 if (item.is_complete || (item.is_applicable == false))
    end
    self.save
  end

  def documents
    [self.self_documents, self.item_documents].flatten
  end

  def has_topics?
    self.items.each do|i|
      if i.item_template.topics.publish.count>0
        return true
      end
    end
    false
  end

  #  unused funcion
  def recently_updated_item
    return Item.find(:all,:conditions=>["is_applicable = ? and section_id = ?",true, self.id], :order=>["updated_at desc"], :limit=>1)
  end

  #  def self.sections_as_per_completed(project_id)
  #    sections = Section.find(:all,
  ##      :select=>['sections.*,items.id'],
  #      :group=>['sections.id'],
  #      :joins=>[:items],
  #      :conditions=>['items.section_id = sections.id and items.is_applicable = ? and project_id=? and items_completed_count >?',true,project_id, 0],
  #      :order=>['items.is_complete desc, items.updated_at desc'],
  #      :limit=>3)
  #    return sections
  #  end


  def self.sections_as_per_completed(project_id)
    sections = Section.find(:all,
      :group=>['sections.id'],
      :joins=>[:items],
      :conditions=>['items.section_id = sections.id and items.is_applicable = ? and project_id=? and items_completed_count >?',true,project_id, 0],
      :order=>['items.is_complete desc, items.updated_at desc'],
      :limit=>3)
    return sections
  end


  def percent_completed
    ((self.items_completed_count*100)/self.items.count)
  end

  def first_applicable_but_not_completed_item
    self.items.are_applicable.are_not_complete.sequence_wise.only(1).first
  end

  def update_deadline(date)
    if self.update_attribute(:due_date, (date.kind_of?(Date)) ? date : Date.parse(date))
      self.project.update_deadline
    end
  end
  
  def is_first_section?
    (self.sequence_number == 1) ? true : false
  end
  
end
