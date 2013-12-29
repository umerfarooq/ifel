module FaqsHelper
  def helper_get_sanitized_faq_categories
    FaqCategory.all.each{|fq| fq.title.replace(strip_tags(fq.title))}
  end
end
