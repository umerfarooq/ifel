class Touchpoint < ActiveRecord::Base
  belongs_to :project

  named_scope :activated, :conditions => {:is_active => true}
  named_scope :inactivated, :conditions => {:is_active => false}
  named_scope :closed, :conditions => {:is_complete => true}
  named_scope :opened, :conditions => {:is_complete => false}
  named_scope :project_wise, :order => 'project_id DESC'

  def activate
    self.is_active = true
    self.save
  end

  def close
    self.is_complete = true
    self.save
  end

  def deliver_touchpoint_email(subject, quote, paragraphs)
    TouchpointMailer.deliver_touchpoint_email(self.project, subject, quote, paragraphs)
  end

#  def Touchpoint.set_touchpoints
#    Touchpoint.opened.inactivated.project_wise.each { |tp| tp.activate if tp.accurate? }
##    Project.all.each do |project|
##      project.touchpoints.opened.inactivated.each do |touchpoint|
##        if touchpoint.accurate?
##          touchpoint.activate
##        end
##      end
##    end
#  end
#
#  def Touchpoint.run_all
#    tp_templates = YAML::load_file(Rails.root.join("config", "touchpoint_templates.yml"))
#    Touchpoint.opened.activated.project_wise.each do |tp|
#      tp
#    end
#  end

  def accurate?
#    puts "One"
    if self.condition.index("_to_").nil?
      simplified_condition = self.condition
    else
      simplified_condition = Touchpoint.to_to_and(self.condition)
    end
#    puts "two"
    phrases = simplified_condition.split("_and_")
    phrases.each do |phrase|
      words = phrase.split("_")
      if(phrase.index("_all_"))
        if(words.count == 3) # "ended_all_items"
#          self.project.sections.each do |section|
#            if(words[0] == "completed")
#              return false unless section.completed?
#            else
#              return false unless section.ended?
#            end
#          end
          if(words[0] == "completed")
            return false unless self.project.items.count == self.project.items.completed.count
          else
            return false unless self.project.items.count == self.project.items.ended.count
          end
        else  # "ended_all_items_in_section_X"
          if(words[0] == "completed")
            return false unless self.project.sections.find_by_sequence_number(words[5]).completed?
          else
            return false unless self.project.sections.find_by_sequence_number(words[5]).ended?
          end
        end
      elsif(phrase.index("_minimum_")) # "completed_minimum_1_item_in_section_2"
        if(words[0] == "completed")
          return false unless self.project.sections.find_by_sequence_number(words[6]).completed_items_count >= words[2].to_i
        else
          return false unless self.project.sections.find_by_sequence_number(words[6]).ended_items_count >= words[2].to_i
        end
      else # "completed_item_5_in_section_1"
        if(words[0] == "completed")
          return false unless self.project.sections.find_by_sequence_number(words[5]).items.find_by_sequence_number(words[2]).completed?
        else
          return false unless self.project.sections.find_by_sequence_number(words[5]).items.find_by_sequence_number(words[2]).ended?
        end
      end
#    puts "three"
    end
    return true
  end

  private
  def Touchpoint.to_to_and(condition)
    phrases = condition.split("_and_")
    phrase_collection = []
    phrases.each do |phrase|
      phrase_collection << phrase and next if phrase.index("_to_").nil?
#      phrase => "completed_sections_2_to_5"
#      phrase => "ended_items_1_to_5_in_section_2"
      sec = phrase.split("_in_section_")[1]
      if sec.blank?
        words = phrase.split("_") # => "completed_sections_2_to_5".split("_")
        phrase_collection << phrase and next unless((words[1] == "sections")&&(words[3] == "to"))
        numbers = words[2].to_i .. words[4].to_i
        (numbers).each do |number|
          phrase_collection << [words[0], words[1].singularize, number].join("_")
        end
      else
        words = phrase.split("_in_section_")[0].split("_") # => "ended_items_1_to_5".split("_")
        phrase_collection << phrase and next unless((words[1] == "items")&&(words[3] == "to"))
        numbers = words[2].to_i .. words[4].to_i
        (numbers).each do |number|
          phrase_collection << [words[0], words[1].singularize, number, "in_section", sec].join("_")
        end
      end
    end
    phrase_collection.join("_and_")
  end

end
