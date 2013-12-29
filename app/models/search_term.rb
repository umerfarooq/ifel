class SearchTerm < ActiveRecord::Base
  named_scope :between, lambda {|start_date, end_date| {:conditions => ["created_on >= ? AND created_on <= ?", start_date, end_date]}}
  named_scope :term_wise, :order => 'term ASC'
  named_scope :date_wise, :order => 'created_on ASC'
  named_scope :term_then_date_wise, :order => 'term ASC, created_on ASC'

  def SearchTerm.searched(term, referer, searched_on)
    if(SearchTerm.new_search?(term, referer))
      st = SearchTerm.find_or_create_by_term_and_created_on(term, Date.today, :count => 0, :searched_on => searched_on)
      SearchTerm.update_counters(st, :count => 1)
    end
  end

  private
  def SearchTerm.new_search?(term, referer=nil)
    uri = URI.parse(referer)
    uri_params = CGI.parse(uri.query)
    #    logger.debug "(#{uri.host.inspect} == #{SITE_HOST_NAME.inspect})&&(#{uri.path.inspect} == #{SEARCH_PATH.inspect})&&(#{uri_params[SEARCH_FIELD].inspect} == #{[term].inspect})"
    #    logger.debug "__REFERER_#{referer.inspect}__"
    if((uri.host == SITE_HOST_NAME)&&(uri.path == SEARCH_PATH)&&(uri_params[SEARCH_FIELD] == [term]))
      return false
    else
      return true
    end
  rescue
    return true
  end
end
