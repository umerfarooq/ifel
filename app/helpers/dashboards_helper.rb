module DashboardsHelper



  def set_class(section)
    days = section.due_date-Date.today
    if days < 0
      class_string = "deadlineDate"
    elsif days <= 3
      class_string = "deadlineDateYellow"
    else
      class_string = "deadlineDateBlack"
    end
    return class_string
  end

  def show_banner_notification?(section)
    show = false
    if section.due_date.present?
      days = section.due_date-Date.today
      if days < 0 or days <= 3
        show = true
      end
    end
    return show
  end
  
  def get_incomplete_items_of_section(section)
    section.items.sequence_wise.are_applicable.are_not_complete
  end

  def helper_get_file_extension(filename)
    defaulticon = "icn-file.png"
    if filename
      splitted_name = filename.split('.')
      extension = splitted_name[(splitted_name.length-1)].to_s
      if File.exist?("#{RAILS_ROOT}/public/images/icn-#{extension}.png")
        defaulticon = "icn-#{extension}.png"
      end
    end
    return defaulticon
  end
  

end
