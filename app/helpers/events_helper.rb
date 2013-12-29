module EventsHelper
  def helper_build_hour_array
    (1..12).to_a
  end

  def helper_build_min_array
    (0..59).to_a
  end
  def helper_build_meridlum_array
    ['am', 'pm']
  end
  def helper_parse_location(summary)
    summary.to_s.split("&lt;br&gt;")[2].split('Where:')
  end

  def helper_parse_time(time)
    meridlum = (time.hour.to_i >= 12.to_i) ? 'pm' : 'am'
    hour = (time.hour.to_i > 12.to_i) ? (time.hour.to_i - 12.to_i).to_i : (time.hour.to_i == 00) ? 12 : time.hour.to_i
    { :hour => hour, :minute => time.min.to_i, :meridlum => meridlum }
  end

  def helper_is_single_day_event?(event)
    if event.class == Event
      return event.event_start_date == event.event_end_date
    end
    return true
  end

  def helper_get_event_city(event)
    if event.class == Feed
      return event.feeder.feed_city
    end
    return event.city
  end

  def helper_get_event_state(event)
    if event.class == Feed
      return event.feeder.feed_geo_state
    end
    return event.geo_state
  end
  
  def helper_get_event_image_path(event)
    if event.class==Feed
      return event.feeder.logo.url(:medium)
    end
    return event.picture.url(:medium)
  end

  def helper_get_event_link(event)
    if event.class==Feed
      return event.link
    end
    return event
  end

  def helper_get_target_value(event)
    if event.class==Feed
      return '_blank'
    end
    return '_self'
  end

  def helper_event_has_same_dates?
    @event.event_start_date == @event.event_end_date
  end

  def helper_event_has_same_times?
    @event.event_start_time == @event.event_end_time
  end
end
