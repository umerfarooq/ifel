class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  after_destroy :destroy_tag_if_unused
  
  def self.tags_associated_to_resources
    Tagging.find(:all,
      :select=>"taggings.tag_id, COUNT(taggings.tag_id) AS no_of_tags, tags.name AS tag_name",
      :joins=>"INNER JOIN resources ON taggings.taggable_id=resources.id
                          INNER JOIN tags ON taggings.tag_id=tags.id",
      :conditions=>{'taggings.taggable_type'=>'Resource','resources.state_id'=>3},
      :group=>"tags.id",
      :order=>"tags.name")
  end
  
  private
  
  def destroy_tag_if_unused
    if Tag.destroy_unused
      if tag.taggings.count.zero?
        tag.destroy
      end
    end
  end
end
