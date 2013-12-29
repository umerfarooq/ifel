# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def meta(meta_description)
    content_for(:meta) { meta_description}
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args.map(&:to_s)) }
  end

  def javascript(*args)
    args = args.map { |arg| arg == :defaults ? arg : arg.to_s }
    content_for(:head) { javascript_include_tag(*args) }
  end

  def logged_in?
    !current_user.nil?
  end

  def will_collection_paginate
    '<div class="collection_paginate"><span style="float:left">'+@prev+'</span><span style="float:right">'+@next+'</span></div>'
  end

  def wsl_linkify(wsl, project)
    ws_link = wsl
    if wsl.index("{_SOI_}") # Section Or Item
      if wsl.split("{_SOI_}")[0].split("_").count == 3
        ws_link = link_to(wsl.split("{_SOI_}")[1], display_section_url(project.sections.find_by_sequence_number(wsl.split("{_SOI_}")[0].split("_")[1]), :host => SITE_HOST_NAME), :style => "color:#f89b4b; text-decoration:none;")
      else
        ws_link = link_to(wsl.split("{_SOI_}")[1], display_item_url(project.sections.find_by_sequence_number(wsl.split("{_SOI_}")[0].split("_")[1]).items.find_by_sequence_number(wsl.split("{_SOI_}")[0].split("_")[3]), :host => SITE_HOST_NAME), :style => "color:#f89b4b; text-decoration:none;")
      end
      ws_link = "#{wsl.split("{_SOI_}")[3]}#{ws_link}#{wsl.split("{_SOI_}")[2]}"
    elsif wsl.index("{_LOC_}")
      ws_link = link_to(wsl.split("{_LOC_}")[1], wsl.split("{_LOC_}")[0], :host => SITE_HOST_NAME, :style => "color:#f89b4b; text-decoration:none;")
      ws_link = "#{wsl.split("{_LOC_}")[3]}#{ws_link}#{wsl.split("{_LOC_}")[2]}"
    elsif wsl.index("{_LEM_}")
      ws_link = mail_to(wsl.split("{_LEM_}")[0], wsl.split("{_LEM_}")[1], :style => "color:#f89b4b; text-decoration:none;")
      ws_link = "#{wsl.split("{_LEM_}")[3]}#{ws_link}#{wsl.split("{_LEM_}")[2]}"
    elsif wsl.index("{_POT_}")
      ws_link = "<strong style='font-family: Trebuchet MS,Arial,Helvetica,sans-serif; font-size: 13px; color:#f89b4b;'>#{wsl.split("{_POT_}")[1]}#{project.percent}#{wsl.split("{_POT_}")[0]}</strong>"
    end
    return ws_link
  end

  def ws_date_format(date)
    date.strftime("%B %d, %Y")
  end

  def ws_date_format_with_abreviated_month(date)
    date.strftime("%b %d, %Y")
  end

  def ws_date_abbriviated_month_format_with_time_and_meridiem_first(date)
    date.strftime("%H:%M %p, %b %d, %Y")
  end
  def ws_date_format_with_time(date)
    date.strftime("%B %d, %Y %H:%M")
  end
  def ws_date_format_with_time_and_meridiem_first_with_day(date)
    "#{date.strftime("%H:%M %p")} on #{ws_day_name date.wday}"
  end
  def ws_date_format_with_time_and_meridiem_first(date)
    date.strftime("%H:%M %p, %B %d, %Y")
  end
  def ws_day_name(day_no)
    day_name = ""
    case day_no
    when 0
      day_name = 'Sunday'
    when 1
      day_name = 'Monday'
    when 2
      day_name = 'Tuesday'
    when 3
      day_name = 'Wednesday'
    when 4
      day_name = 'Thursday'
    when 5
      day_name = 'Friday'
    when 6
      day_name = 'Saturday'
    end
    day_name
  end
  def ws_time_format(time)
    time.strftime("%I:%M %P")
  end
  def ws_date_format_with_city_and_state(date, city, state)
    date.strftime("%B %d, %Y#{(', '+city.to_s unless city.blank?)}#{(', '+state.to_s unless state.blank?)}")
  end

  def ws_slash_separated_date_format(date)
    date.strftime("%d/%m/%Y")
  end
  
  def ws_slash_separated_month_day_year_date_format(date)
    date.strftime("%m/%d/%y")
  end

  def ws_time_format_with_meridiem_and_timezone(time)
    "#{time.strftime("%H:%M %p")} #{time.zone.to_s}"
  end

  def get_user_community_inbox_count(user)
    count = 0
    user.messages.each do |msg|
      count += msg.comments.not_viewed.count
    end
    count
  end
  
  def sort_link(title, column, options = {})
#    condition = options[:unless] if options.has_key?(:unless)
    sort_dir = ((params[:d] == 'asc') ? 'desc' : 'asc' if params[:d])
    link_to title, request.parameters.merge( {:c => column, :d => (sort_dir.blank?) ? 'desc' : sort_dir } )
#    link_to_unless condition, title, request.parameters.merge( {:c => column, :d => sort_dir} )
  end
  def is_on_resources_page?(params)
    (params[:controller] == "resources" and params[:action] == 'index') or (params[:controller] == "info" and params[:action] == "search")
  end
end


#{_WSL_}LINK_DESTINATION{_SOI_}LINK_TEXT{_SOI_}LINK_POST_TEXT{_SOI_}LINK_PRE_TEXT{_WSL_}
#{_WSL_}LINK_DESTINATION{_LOC_}LINK_TEXT{_LOC_}LINK_POST_TEXT{_LOC_}LINK_PRE_TEXT{_WSL_}
#{_WSL_}EMAIL_DESTINATION{_LEM_}EMAIL_TEXT{_LEM_}EMAIL_POST_TEXT{_LEM_}EMAIL_PRE_TEXT{_WSL_}
#{_WSL_}POST_POT{_POT_}PRE_POT{_WSL_}

#{_WSL_}SECTION_4_ITEM_1{_SOI_}Find a CPA{_SOI_},\"{_SOI_}\"{_WSL_}
#{_WSL_}SECTION_2_SUMMARY{_SOI_}Click here{_WSL_}
#{_WSL_}%{_POT_}{_WSL_}
#{_WSL_}info@wickedstart.com{_LEM_}email us{_WSL_}

#"SECTION_4_ITEM_1{_SOI_}Find a CPA{_SOI_},\"{_SOI_}\"".split("{_SOI_}")
