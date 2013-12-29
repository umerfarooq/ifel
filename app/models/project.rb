class Project < ActiveRecord::Base
  belongs_to :user
  has_many :sections, :dependent => :destroy
  has_many :items, :through => :sections, :dependent => :destroy
  has_many :todos, :through => :sections, :dependent => :destroy
  #  has_many :documents
  has_many :messages, :dependent => :destroy
  has_many :touchpoints, :dependent => :destroy

  before_create :set_creation_defaults
  after_create :populate_items_and_sections

  attr_accessible         :business_name, :start_date, :max_days

  #TODO VALIDATION FOR RELATIONSHIPS

  # TODO [9/14/10 9:05 PM] => REFACTOR MAX_DAYS AND BEFORE_CREATE
  def set_creation_defaults
    if self.max_days == 0
      self.max_days = nil
      self.end_date = nil
    else
      self.end_date = self.start_date + self.max_days
    end
    self.percent = 0
  end

  #TODO USE CONSTANTS AS MUCH AS U CAN
  def populate_items_and_sections
    RAILS_DEFAULT_LOGGER.info "_S__Project________populate_items_and_sections________________#{Time.now}____"
    RAILS_DEFAULT_LOGGER.info "Project (id, #{self.id}), (name, #{self.business_name}), (start_date, #{self.start_date}), (end_date, #{self.end_date})"
    
    if self.user.associated_with_ifel
      section_templates = SectionTemplate.ifel.published.sequence_wise
    else
      section_templates = SectionTemplate.wibo.published.sequence_wise  
    end
    
    unless section_templates.blank?
      section_templates.each do |st|
        #      next if st.item_templates.find_all_by_state_id(State.find_by_name('publish').id).blank?
        next if st.item_templates.published.blank?
        section = Section.new(
          :name => st.name,
          :sequence_number => st.sequence_number,
          :title => st.title,
          :title_comment => st.title_comment,
          :introduction => st.introduction
        )
        section.item_count = st.item_templates.published.count
        section.items_completed_count = 0
        section.do_show_intro = true
        case self.max_days
        when 30
          section.due_date = self.start_date + st.due_days_30.to_i
        when 60
          section.due_date = self.start_date + st.due_days_60.to_i
        when 120
          section.due_date = self.start_date + st.due_days_120.to_i
        else
          section.due_date = nil
        end
        section.section_template = st
        section.project = self
        #      self.sections << section
        section.save
        st.item_templates.published.sequence_wise.each do |it|
          item = Item.new(
            :item_number => it.item_number,
            :sequence_number => it.sequence_number,
            :title => it.title,
            :definition => it.definition,
            :percent => it.percent,
            :has_textbox => it.has_textbox,
            :has_upload => it.has_upload
          )
          item.is_complete = false
          item.is_applicable = true
          item.item_template = it
          item.section = section
          #        sect.items << item
          #        item.section.project = self
          item.save
        end
      end
      self.open_section = self.sections.first.id
      tp_templates = YAML::load_file(Rails.root.join("config", "touchpoint_templates.yml"))
      tp_templates.each_key { |key| self.touchpoints << Touchpoint.create(:condition => key, :is_active => false, :is_complete => false) }
      self.save
      RAILS_DEFAULT_LOGGER.info "Project (id, #{self.id}), (section_count, #{self.sections.count}), (item_count, #{self.items.count}), (touchpoint_count, #{self.touchpoints.count})"
      RAILS_DEFAULT_LOGGER.info "_E__Project________populate_items_and_sections________________#{Time.now}____"
    end
  end

  def update_percentage
    percentage = 0.0
    self.items.each do |item| 
      if (item.is_complete || item.is_not_applicable)
        percentage = percentage + item.percent
      end
    end
    self.percent = percentage
    self.save
  end

  def documents
    docs = []
    self.sections.each { |section| docs << section.documents }
    docs.flatten
  end

  def get_lastly_worked_on_section
    section = (self.open_section.blank?) ? self.sections.first : (Section.find(self.open_section) rescue nil)
    unless section.present?
      return self.sections.first
    end
    return section
  end

  def is_in_progress?
    self.percent > 0
  end

  def get_lastly_worked_on_items
    self.items.are_applicable.are_not_complete.are_in_progress.only(3)
    #    if self.is_in_progress?
  end

  def get_closely_due_section
    self.sections.due_date_wise.are_not_in_the_past.not_completed.each do|section|
      return section unless section.completed?
    end
    return nil
  end

  def get_upcoming_todos
    self.todos.are_not_in_past.are_not_completed.upcoming.only(3)
  end

  def sections_in_range range
    self.sections.find(:all,:conditions=>["sections.id IN(?)",range.collect { |id| id.to_i }])
  end

  def update_deadline(deadline=nil)
    if deadline 
      self.update_attribute(:end_date,(deadline.kind_of?(Date)) ? deadline : Date.parse(deadline))
    else
      date_wise_sections = self.sections.due_date_wise
      unless date_wise_sections.blank?
        self.update_attribute(:end_date,date_wise_sections.last.due_date)
      end
    end
  end

  def set_opened_section(section_id)
    self.update_attribute(:open_section, section_id.to_i)
  end
  
end
