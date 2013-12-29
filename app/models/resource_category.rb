class ResourceCategory < ActiveRecord::Base
  belongs_to :state
  has_many :resources

  #  before_create :set_creation_defaults

  attr_accessible :name, :title, :description
  validates_presence_of :title

  #  def set_creation_defaults
  #    self.is_active = true
  #    self.state_id = (State.find_by_title("create")).id
  #  end

  named_scope :published, :conditions => { :state_id => State.find_by_name('publish').id }
  named_scope :sorted, :order => 'title asc'
  
  
  def self.service_provider
    ResourceCategory.find_by_title('Service Provider')
  end

  # Function to compute the Top Trending Resource Categories based on the Number of resources assigned in a month-time
  #

  # Old one
  #  def self.top_trending_types_for_resource_library(options={})
  #    joins = []
  #    conditions = ["resourcifications.created_at >=? and resources.state_id =? and resource_categories.title !=? and resourcifications.state_id =?",(Date.today-(1.month)), 3, 'Service Provider', 3]
  #    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
  #    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #    joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #    joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #
  #    end
  #    ResourceCategory.find(
  #      :all,
  #      :select => 'resource_categories.id, resource_categories.title, COUNT(distinct resources.id) AS no_of_resources_in_a_month',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resource_categories.id',
  #      :order => 'no_of_resources_in_a_month DESC',
  #      :limit => options[:limit] || 10)
  #  end

  # editted by muzammil
  def self.top_trending_types_for_resource_library(options={})
    joins = []
    conditions = ["resourcifications.created_at >=? and resources.state_id =? and resource_categories.title !=? and resourcifications.state_id =?",(Date.today-(1.month)), 3, 'Service Provider', 3]
    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end
    ResourceCategory.find(
      :all,
      :select => 'resource_categories.id, resource_categories.title, COUNT(distinct resources.id) AS no_of_resources_in_a_month',
      :joins => joins,
      :conditions => conditions,
      :group => 'resource_categories.id',
      :order => 'no_of_resources_in_a_month DESC',
      :limit => options[:limit] || 10)
  end

  # old one
  #  def self.all_categories_for_section_in_resource_library(options={})
  #    joins = []
  #    conditions = ["resources.state_id =? and resourcifications.state_id =?", 3, 3]
  #    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
  #    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #    joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #    joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #    end
  #    ResourceCategory.find(
  #      :all,
  #      :select => 'resource_categories.id, resource_categories.title, COUNT(distinct resources.id) AS no_of_resources_in_a_month',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resource_categories.id',
  #      :order => 'no_of_resources_in_a_month DESC',
  #      :limit => options[:limit] || 10)
  #  end

  #editted by muzammil
  def self.all_categories_for_section_in_resource_library(options={})
    joins = []
    conditions = ["resources.state_id =?",3]
    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end
    ResourceCategory.find(
      :all,
      :select => 'resource_categories.id, resource_categories.title, COUNT(distinct resources.id) AS no_of_resources_in_a_month',
      :joins => joins,
      :conditions => conditions,
      :group => 'resource_categories.id',
      :order => 'no_of_resources_in_a_month DESC',
      :limit => options[:limit] || 10)
  end



    def resources_of_categories(options={})
      joins = []
      conditions = ["resourcifications.state_id =?", 3]
      joins << "LEFT JOIN taggings ON (taggings.taggable_id = resources.id AND taggings.taggable_type ='Resource')"
      joins << "INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
      joins << "INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
      joins << "INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"

      if options[:section_template_id]
        conditions[0] << " AND section_templates.id =?"
        conditions << options[:section_template_id]
      end
      self.resources.published.find(
        :all,
        :select => 'resources.*, COUNT(taggings.tag_id) AS number_of_tags_in_a_month, section_templates.id AS section',
        :joins => joins,
        :conditions => conditions,
        :group => 'resources.id',
        :order => 'section ASC',
        :limit => options[:limit] || 1000)
    end

  # following updated by muzammil

#  def resources_of_categories(options={})
#    if options[:section_template_id]
#      conditions[0] << " AND resources.id IN(?)"
#      if(options[:resources])
#        conditions << options[:resources]
#      else
#        conditions << SectionTemplate.resource_ids(options[:section_template_id])
#      end
#    end
#    self.resources.published.find(
#      :all,
#      :select => 'resources.*',
#      :group => 'resources.id',
#      :order => 'resources.name ASC',
#      :limit => options[:limit] || 1000)
#  end


  #  def resources_of_category(options={})
  #    joins = []
  #    conditions = ["resourcifications.state_id =?", 3]
  #    joins << "LEFT JOIN taggings ON (taggings.taggable_id = resources.id AND taggings.taggable_type ='Resource')"
  #    joins << "INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #    joins << "INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #    joins << "INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #    end
  #    if options[:top_trending]
  #      conditions[0] << " AND resourcifications.created_at >=?"
  #      conditions << (Date.today-(1.month))
  #    end
  #    self.resources.published.find(
  #      :all,
  #      :select => 'resources.*, COUNT(taggings.tag_id) AS number_of_tags_in_a_month, section_templates.id AS section',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resources.id',
  #      :order => 'resources.name ASC',
  #      :limit => options[:limit] || 1000)
  #  end

  # Updated with conditional joins by muzammil
  def resources_of_category(options={})
    joins = []
    conditions=["1"]
    if options[:top_trending]
      joins << "INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
      conditions[0] << " AND resourcifications.created_at >=?"
      conditions << (Date.today-(1.month))
    end
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end
    self.resources.published.find(
      :all,
      :select => 'resources.*',
      :joins => joins,
      :conditions => conditions,
      :group => 'resources.id',
      :order => 'resources.title ASC',
      :limit => options[:limit] || 1000)
  end


  #should be having no check on section template
  def self.all_tags(options={})
    joins = []
    conditions = ["taggings.taggable_type=? and resources.state_id =?", 'Resource', 3]
    joins << "INNER JOIN taggings ON taggings.tag_id=tags.id"
    joins << "INNER JOIN resources ON resources.id = taggings.taggable_id"

    # old one
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    end

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    #    Tag.find(
    #      :all,
    #      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
    #      :joins => joins,
    #      :conditions => conditions,
    #      :group => 'tags.id',
    #      :order => 'no_of_tags DESC',
    #      :limit => options[:limit] || 10,
    #      :offset => options[:offset] || 0)

    #    changed to following by muzammil
    Tag.find(
      :all,
      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'tags.id',
      :order => 'tags.name ASC',
      :limit => options[:limit] || 10,
      :offset => options[:offset] || 0)
  end


  def self.all_tags_service_provider(options={})
    joins = []
    conditions = ["taggings.taggable_type=? and resources.state_id =? and resource_categories.title  =?", 'Resource', 3, 'Service Provider']
    joins << "INNER JOIN taggings ON taggings.tag_id=tags.id"
    joins << "INNER JOIN resources ON resources.id = taggings.taggable_id"
    joins << "INNER JOIN resource_categories ON resource_categories.id = resources.resource_category_id"

    # old one
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    end
    #
    #

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    #    Tag.find(
    #      :all,
    #      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
    #      :joins => joins,
    #      :conditions => conditions,
    #      :group => 'tags.id',
    #      :order => 'no_of_tags DESC',
    #      :limit => options[:limit] || 10,
    #      :offset => options[:offset] || 0)

    #     changed by muzammil for issue number 20252

    Tag.find(
      :all,
      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'tags.id',
      :order => 'tags.name ASC',
      :limit => options[:limit] || 10,
      :offset => options[:offset] || 0)

    #     20252 Change End
  end


  def self.top_tags_for_resource_library(options={})
    joins = []
    conditions = ["taggings.created_at >=? AND taggings.taggable_type=? and resources.state_id =?", (Date.today-(1.month)), 'Resource', 3]
    joins << "INNER JOIN taggings ON taggings.tag_id=tags.id"
    joins << "INNER JOIN resources ON resources.id = taggings.taggable_id"
    joins << "INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id"
    # old one
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    end

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    Tag.find(
      :all,
      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'tags.id',
      :order => 'no_of_tags DESC',
      :limit => options[:limit] || 10,
      :offset => options[:offset] || 0)
  end


  def self.top_tags_for_service_provider(options={})
    joins = []
    conditions = ["taggings.created_at >=? AND taggings.taggable_type=? and resources.state_id =? and resource_categories.title =?", (Date.today-(1.month)), 'Resource', 3, 'Service Provider']
    joins << "INNER JOIN taggings ON taggings.tag_id=tags.id"
    joins << "INNER JOIN resources ON resources.id = taggings.taggable_id"
    joins << "INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id"

    # old one
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    end

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    Tag.find(
      :all,
      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'tags.id',
      :order => 'no_of_tags DESC',
      :limit => options[:limit] || 10,
      :offset => options[:offset] || 0)
  end





  #    def self.top_trending_service_provider(options={})
  #    joins = []
  #    conditions = ["resourcifications.created_at >=? and resources.state_id =? and resource_categories.title =? and resourcifications.state_id =?",(Date.today-(1.month)), 3, 'Service Provider', 3]
  #    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
  #    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #    joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #    joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #
  #    end
  #    ResourceCategory.find(
  #      :all,
  #      :select => 'resource_categories.id, resource_categories.title, COUNT(resources.id) AS no_of_resources_in_a_month',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resource_categories.id',
  #      :order => 'no_of_resources_in_a_month DESC',
  #      :limit => options[:limit] || 10)
  #  end
  #
  #
  #
  #    def self.top_trending(options={})
  #    joins = []
  #    conditions = ["resourcifications.created_at >=? and resources.state_id =? and resource_categories.title !=? and resourcifications.state_id =?",(Date.today-(1.month)), 3, 'Service Provider', 3]
  #    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
  #    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #    joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #    joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #
  #    end
  #    ResourceCategory.find(
  #      :all,
  #      :select => 'resource_categories.id, resource_categories.title, COUNT(resources.id) AS no_of_resources_in_a_month',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resource_categories.id',
  #      :order => 'no_of_resources_in_a_month DESC',
  #      :limit => options[:limit] || 10)
  #  end










  #    def self.top_tags(options={})
  #    joins = []
  #    conditions = ["taggings.created_at >=? AND taggings.taggable_type=? and resources.state_id =?", (Date.today-(1.month)), 'Resource', 3]
  #    joins << "INNER JOIN taggings ON taggings.tag_id=tags.id"
  #    joins << "INNER JOIN resources ON resources.id = taggings.taggable_id"
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #    end
  #    Tag.find(
  #      :all,
  #      :select => 'tags.id,tags.name,COUNT(taggings.tag_id) AS no_of_tags',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'tags.id',
  #      :order => 'no_of_tags DESC',
  #      :limit => options[:limit] || 10,
  #      :offset => options[:offset] || 0)
  #  end





  def self.top_trending_service_provider(options={})
    joins = []
    conditions = ["resourcifications.created_at >=? and resources.state_id =? and resource_categories.title =? and resourcifications.state_id =?",(Date.today-(1.month)), 3, 'Service Provider', 3]
    joins << " INNER JOIN resources ON resources.resource_category_id = resource_categories.id"
    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    # old one
    #    joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #    joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #    joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #
    #    end

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    ResourceCategory.find(
      :all,
      :select => 'resource_categories.id, resource_categories.title, COUNT(resources.id) AS no_of_resources_in_a_month',
      :joins => joins,
      :conditions => conditions,
      :group => 'resource_categories.id',
      :order => 'no_of_resources_in_a_month DESC',
      :limit => options[:limit] || 10)
  end

  # Function to compute the Top Trending Resources of a Resource Category based on the Number of Tags assigned in a month-time


  # function not in use
  #    def resources_of_categories(options={})
  #    joins = []
  #    conditions = [" resources.created_at >=? and resourcifications.state_id =?", (Date.today-(1.month)), 3]
  #    joins << "LEFT JOIN taggings ON (taggings.taggable_id = resources.id AND taggings.taggable_type ='Resource')"
  #    joins << "LEFT JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #    joins << "INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #    joins << "INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #    end
  #    self.resources.published.find(
  #      :all,
  #      :select => 'resources.*, section_templates.id AS section',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resources.id',
  #      :order => 'section ASC',
  #      :limit => options[:limit] || 3)
  #  end










  def self.tag_resources_service_provider(options ={})
    joins = []
    conditions = ["taggings.taggable_type=? AND tags.id =? AND resources.state_id =? and resource_categories.title =?",'Resource', options[:tag_id].to_i, 3,'Service Provider']
    joins << "INNER JOIN taggings ON taggings.taggable_id=resources.id"
    joins << "INNER JOIN tags ON taggings.tag_id=tags.id"
    joins << "INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id"

    # old done
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    end

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    if options[:is_top_tag] == "true"
      conditions[0] << " AND taggings.created_at >=?"
      conditions << (Date.today-(1.month))
    end
    Resource.find(
      :all,
      :select => 'tags.name AS tag_name, resources.*, COUNT( taggings.tag_id ) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'resources.id',
      :order => 'no_of_tags DESC')
  end

  # old one
  #  def self.tag_resources_resource_library(options ={})
  #    joins = []
  #    conditions = ["taggings.taggable_type=? AND tags.id =? AND resources.state_id =?",'Resource', options[:tag_id].to_i, 3]
  #    joins << "INNER JOIN taggings ON taggings.taggable_id=resources.id"
  #    joins << "INNER JOIN tags ON taggings.tag_id=tags.id"
  #    joins << "INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id"
  #    if options[:section_template_id]
  #      conditions[0] << " AND section_templates.id =?"
  #      conditions << options[:section_template_id]
  #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
  #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
  #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
  #    end
  #    if options[:is_top_tag] == "true"
  #      conditions[0] << " AND taggings.created_at >=?"
  #      conditions << (Date.today-(1.month))
  #    end
  #    Resource.find(
  #      :all,
  #      :select => 'tags.name AS tag_name, resources.*, COUNT( taggings.tag_id ) AS no_of_tags',
  #      :joins => joins,
  #      :conditions => conditions,
  #      :group => 'resources.id',
  #      :order => 'no_of_tags DESC')
  #  end

  # dited by mzammil
  def self.tag_resources_resource_library(options ={})
    joins = []
    conditions = ["taggings.taggable_type=? AND tags.id =? AND resources.state_id =?",'Resource', options[:tag_id].to_i, 3]
    joins << "INNER JOIN taggings ON taggings.taggable_id=resources.id"
    joins << "INNER JOIN tags ON taggings.tag_id=tags.id"
    joins << "INNER JOIN resource_categories ON resources.resource_category_id = resource_categories.id"
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end
    if options[:is_top_tag] == "true"
      conditions[0] << " AND taggings.created_at >=?"
      conditions << (Date.today-(1.month))
    end
    Resource.find(
      :all,
      :select => 'tags.name AS tag_name, resources.*, COUNT( taggings.tag_id ) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'resources.id',
      :order => 'no_of_tags DESC')
  end

  def self.tag_resources(options ={})
    joins = []
    conditions = ["taggings.created_at >=? AND taggings.taggable_type=? AND tags.id =? AND resources.state_id =?", (Date.today-(1.month)), 'Resource', options[:tag_id].to_i, 3]
    joins << "INNER JOIN taggings ON taggings.taggable_id=resources.id"
    joins << "INNER JOIN tags ON taggings.tag_id=tags.id"

    #    Old one
    #    if options[:section_template_id]
    #      conditions[0] << " AND section_templates.id =?"
    #      conditions << options[:section_template_id]
    #      joins << " INNER JOIN resourcifications ON resourcifications.resource_id = resources.id"
    #      joins << " INNER JOIN item_templates ON item_templates.id = resourcifications.item_template_id"
    #      joins << " INNER JOIN section_templates ON section_templates.id = item_templates.section_template_id"
    #    end

    #new one by muzammil
    if options[:section_template_id]
      conditions[0] << " AND resources.id IN(?)"
      if(options[:resources])
        conditions << options[:resources]
      else
        conditions << SectionTemplate.resource_ids(options[:section_template_id])
      end
    end

    Resource.find(
      :all,
      :select => 'tags.name AS tag_name, resources.*, COUNT( taggings.tag_id ) AS no_of_tags',
      :joins => joins,
      :conditions => conditions,
      :group => 'resources.id',
      :order => 'no_of_tags DESC')
  end

  def self.get_category(id)
    obj_resource_category = ResourceCategory.find_by_id(id)
    bln_success = 0
    if obj_resource_category
      bln_success = 1
    end
    return obj_resource_category, bln_success
  end

  def self.get_categories
    obj_categories = ResourceCategory.published
    bln_success = 0
    if (obj_categories)
      bln_success = 1
    end
    return obj_categories, bln_success
  end
end
