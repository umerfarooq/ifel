module NewsArticlesHelper
  def helper_news_provider_logo(news_article)
    news_provider = (news_article.class==Feed) ? news_article.feeder : news_article.news_provider       
    link_to image_tag(news_provider.logo.url(:small), :alt => news_provider.title), news_provider.url , :target=>'_blank' if news_provider.present?
  end

  def helper_news_source(news_article)
    (news_article.class==Feed) ? news_article.link : news_article.url
  end

  def helper_news_link(news_article)
    link = ''
    if news_article.class==Feed
      link = news_article.link
      target = '_blank'
    else
      link = news_article
      target = '_parent'
    end
    link_to news_article.title, link, :target=> target
  end

  def helper_news_date(news_article)
    (news_article.class==Feed) ? news_article.published_at : news_article.news_date
  end

  def helper_is_internal_news?(news_article)
    (news_article.class==NewsArticle)
  end
  
  def helper_is_external_news?(news_article)
    (news_article.class==Feed)
  end

  def helper_news_articles_to_show(news_articles)
    (logged_in?) ? news_articles : news_articles[3..-1]
  end

  
end
