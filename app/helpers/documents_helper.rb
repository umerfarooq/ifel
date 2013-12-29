module DocumentsHelper

  # This function is to compute the Type of File, to load the proper File Icon on the View
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

  # This function is to compute the Type of File, to load the proper Large File Icon on the View
  def helper_get_file_extension_big_icon(filename)
    defaulticon = "icn-file-big.png"
    if filename
      splitted_name = filename.split('.')
      extension = splitted_name[(splitted_name.length-1)].to_s
      if File.exist?("#{RAILS_ROOT}/public/images/icn-#{extension}-big.png")
        defaulticon = "icn-#{extension}-big.png"
      end
    end
    return defaulticon
  end

  # This function is primarily used to generate the Unique DOM IDs for multiple Sections
  def helper_generate_unique_dom_id(section)
    #    section.title.downcase.tr(' ','_').concat("_#{section.id.to_s}")
    'section'.concat("_#{section.id.to_s}")
  end

  def helper_is_loggedin_user_owner_of_this_document?(document)
    current_user == document.owner
  end
  
  def helper_document_viewer_software_message(filename)
    message = String.new
    if filename
      splitted_name = filename.split('.')
      extension = splitted_name[(splitted_name.length-1)].to_s
      case extension
      when 'pdf'
        message = "Requires <a href='http://get.adobe.com/reader/' target='_blank'>Adobe PDF Reader</a> or other pdf-compatible application."
      when 'doc'
        message = "Requires <a href='http://office.microsoft.com/en-us/downloads/' target='_blank'>MS Document</a> or other doc-compatible application."
      end
    end
    message
  end
end
