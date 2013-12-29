module SectionsHelper
  def helper_section_name_suffixed_by_sequence(section)
    "#{section.sequence_number.to_s} #{section.section_template.title}"
  end
  def helper_section_name_suffixed_by_sequence_and_colon(section)
    "#{section.sequence_number.to_s}: #{section.section_template.title}"
  end
  def helper_choose_date_color(due_date,section_percentage=0)
    color_class = "colorNormal"
    unless section_percentage == 100
      unless due_date.blank?
        if due_date < Date.today
          color_class = "colorOverdue"
        elsif (Date.today.advance(:days => 2.days) >= due_date and due_date >= Date.today)
          color_class = "colorDue"
        end
      end
    end
    color_class
  end
  def helper_choose_date_icon_large(due_date,section_percentage)
    image = ''
    unless section_percentage == 100
      if due_date < Date.today
        image = '<img src="/images/notify-icn-overdue.png" />'
      elsif (Date.today.advance(:days => 2.days) >= due_date and due_date >= Date.today)
        image = '<img src="/images/notify-icn-due.png" />'
      end
    end
    image
  end
  def helper_choose_date_icon_small( due_date, section_percentage=0)
    image = ''
    unless section_percentage == 100
      if due_date < Date.today
        image = '<img src="/images/notify-icn-overdue.png" />'
      elsif (Date.today.advance(:days => 2.days) >= due_date and due_date >= Date.today)
        image = '<img src="/images/notify-icn-due.png" />'
      end
    end
    image
  end
  
  def helper_get_note_document(section)
    section.self_documents.find_by_is_note(true)
  end
end
