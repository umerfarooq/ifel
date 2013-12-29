module SuccessStoriesHelper
  def helper_strip_off_protocol(url)
    url.split('://')[1]
  end
end
