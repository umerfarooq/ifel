class ItemTemplate < ActiveRecord::Base
  belongs_to :section_template
  belongs_to :state
  has_many :examples, :dependent => :destroy
  has_many :items, :dependent => :destroy

#  has_and_belongs_to_many :topics

  has_many :item_templates_topics, :dependent => :destroy
  has_many :topics, :through => :item_templates_topics
#  has_and_belongs_to_many :resources
#  has_and_belongs_to_many :template_documents

  has_many :resourcifications, :dependent => :destroy
  has_many :resources, :through => :resourcifications
  has_many :templatifications, :dependent => :destroy
  has_many :template_documents, :through => :templatifications

  named_scope :published, :conditions => {:state_id => State.find_by_name('publish').id}
  named_scope :sequence_wise, :order => 'sequence_number ASC'

#  accepts_nested_attributes_for :template_documents, :allow_destroy => :true

#  attr_accessible :item_number, :sequence_number, :title, :definition, :description, :percent, :has_textbox, :has_upload, :is_example_simple, :example_description

#  attr_accessible :item_number, :sequence_number, :title, :definition, :description, :percent, :has_textbox, :has_upload, :is_example_simple, :example_description

  attr_accessible :title, :definition,:description, :percent, :has_textbox, :has_upload, :section_template_id
  validates_presence_of :title, :definition, :description, :percent, :section_template_id

  before_create :set_creation_defaults

#  def ItemTemplate.all_active
#    ItemTemplate.find_all_by_state_id((State.find_by_title("create")).id)
#  end


  def default_topics
    self.item_templates_topics.defaults
  end

  def set_creation_defaults
#    self.item_number = ItemTemplate.maximum("item_number") + 1
    if self.section_template
      self.sequence_number = self.section_template.item_templates.size + 1
    else
      self.sequence_number = 0
    end
    self.is_example_simple = true
    self.example_description = nil
#    self.is_active = true
    self.state_id = (State.find_by_name("inactivate")).id
  end

#  def is_answerable
#    true
#  end

  def self.get_item_template_along_with_section_template_name
    ItemTemplate.find(:all, :select=>[' CONCAT(section_templates.title,"--", item_templates.title) as name,item_templates.id '], :joins=>["INNER JOIN section_templates on section_templates.id=section_template_id"])
  end
  def has_template_document?(td)
    (!td.blank?) && Templatification.find_by_item_template_id_and_template_document_id(@item_template.id, td.id).blank?
  end

  def previous
    if self.sequence_number == 1
#      self.section_template.item_templates[self.section_template.item_count-1]
      self.section_template.item_templates[self.section_template.item_templates.length-1]
    else
      self.section_template.item_templates[self.sequence_number-2]
    end
  end

  def next
#    if self.sequence_number == self.section_template.item_count
    if self.sequence_number == self.section_template.item_templates.length
      self.section_template.item_templates[0]
    else
      self.section_template.item_templates[self.sequence_number]
    end
  end

  def on_top?
#    self.sequence_number == ItemTemplate.minimum(:sequence_number)
    self.sequence_number == self.section_template.item_templates.minimum(:sequence_number)
  end

  def on_bottom?
#    self.sequence_number == ItemTemplate.maximum(:sequence_number)
    self.sequence_number == self.section_template.item_templates.maximum(:sequence_number)
  end

  def move_up
    unless self.on_top?
#      one_up_sno = ItemTemplate.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
#      it_swap = ItemTemplate.find_by_sequence_number(one_up_sno)
      one_up_sno = self.section_template.item_templates.maximum(:sequence_number, :conditions => ['sequence_number < ?', self.sequence_number])
      it_swap = self.section_template.item_templates.find_by_sequence_number(one_up_sno)
      it_swap.sequence_number = self.sequence_number
      self.sequence_number = one_up_sno
      self.save
      it_swap.save
      return true
    else
      return false
    end
  end

  def move_down
    unless self.on_bottom?
#      one_down_sno = ItemTemplate.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
#      it_swap = ItemTemplate.find_by_sequence_number(one_down_sno)
      one_down_sno = self.section_template.item_templates.minimum(:sequence_number, :conditions => ['sequence_number > ?', self.sequence_number])
      it_swap = self.section_template.item_templates.find_by_sequence_number(one_down_sno)
      it_swap.sequence_number = self.sequence_number
      self.sequence_number = one_down_sno
      self.save
      it_swap.save
      return true
    else
      return false
    end
  end
  
  def synchronized
    is_sync = false
    Section.find_in_batches(:conditions => {:section_template_id => self.section_template_id}) do|sections|
      sections.each do|section|
        item = section.items.find_by_item_template_id self.id
        if item
          if item.update_attributes({:title => self.title,:definition => self.definition,:percent => self.percent,:has_textbox => self.has_textbox,:has_upload => self.has_upload })
            is_sync = true
          end
        else
          item = Item.new(
            :item_number => self.item_number,
            :sequence_number => self.sequence_number,
            :title => self.title,
            :definition => self.definition,
            :percent => self.percent,
            :has_textbox => self.has_textbox,
            :has_upload => self.has_upload
          )
          item.is_complete = false
          item.is_applicable = true
          item.item_template = self
          item.section = section
          if item.save
            is_sync = true
          end
        end
      end 
    end
    is_sync
  end

end
