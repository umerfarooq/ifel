# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

config.time_zone = 'Eastern Time (US & Canada)'
config.active_record.default_timezone = :utc
#config.gem 'newrelic_rpm'

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!


#ActionMailer's Setting for Send Mail
config.action_mailer.delivery_method = :sendmail

#ActionMailer's Setting for Send Mail
config.action_mailer.sendmail_settings = {
  :location => '/usr/sbin/sendmail',
  :arguments => '-i -t'
}
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_charset = "iso-8859-1"

Paperclip.options[:command_path] = '/usr/bin'

################################################################################

CUSTOM_LOGGER.level = Logger::INFO


VIDEOS_ON_S3 = true


# Site_url is the url listed in the emails sent to user
SITE_HOST_NAME = "wibo.wickedstart.com"
SITE_URL = "http://wibo.wickedstart.com"

SITE_BASIC_AUTH_ENABLED = false
SITE_BASIC_AUTH_USER = "wickedstart"
SITE_BASIC_AUTH_PASS = "letmein"
SITE_BLOG_PATH = "/blog"
SITE_BLOG_RSS_URL = "http://wibo.wickedstart.com/blog/?feed=rss2"
SITE_BLOGS = ["START UP SMART BLOG", "TEN STEPS TO START UP BLOG", "IN THE TRENCHES BLOG"]
SITE_BLOGS_LINKS = ["http://wibo.wickedstart.com/blog/startupsmart/feed/", "http://wibo.wickedstart.com/blog/tenstepstostartup/feed/", "http://wibo.wickedstart.com/blog/inthetrenches/feed/"]
SITE_BLOGS_TITLES = ["http://wibo.wickedstart.com/blog/startupsmart/", "http://wibo.wickedstart.com/blog/tenstepstostartup/", "http://wibo.wickedstart.com/blog/inthetrenches/"]

TWITTER_RSS_URL = "http://twitter.com/statuses/user_timeline/174692153.rss"
TWITTER_WS_URL = "http://www.twitter.com/wickedstart"
FACEBOOK_WS_URL = "http://www.facebook.com/wickedstart"
LINKED_IN_WS_URL = "http://www.linkedin.com/groups?mostPopular=&gid=3277641"
YOU_TUBE_WS_URL = "http://www.youtube.com/user/WickedStart"

SITE_URL_FOR_MAILS = "http://wibo.wickedstart.com"

#SELF_BLOG_RSS_URL = "http://www.wickedstart.com/blog/?feed=rss2"
#SELF_BLOG_AUTH_USER = "wickedstart"
#SELF_BLOG_AUTH_PASS = "letmein"

LOCK_LOGIN = false
LOCK_SIGNUP = false
LOCK_LOGIN_KEY = :login
LOCK_LOGIN_VALUE = "wsconfiz"
LOCK_SIGNUP_KEY = :signup
LOCK_SIGNUP_VALUE = "wsconfiz"

FRONT_MODULES_MESSAGES_COUNT = 2
FRONT_MODULES_MESSAGE_LENGTH = 200
FRONT_MODULES_RADAR_INTERNAL_COUNT = 2
FRONT_MODULES_RADAR_INTERNAL_LENGTH = 200
FRONT_MODULES_BLOG_INTERNAL_COUNT = 2
FRONT_MODULES_BLOG_INTERNAL_LENGTH = 200

FRONT_MODULES_SUCCESS_STORIES_COUNT = 1
FRONT_MODULES_SUCCESS_STORIES_LENGTH = 200      # NOT_USED
FRONT_MODULES_RADAR_PUBLIC_COUNT = 1
FRONT_MODULES_RADAR_PUBLIC_LENGTH = 200        # NOT_USED
FRONT_MODULES_TWITTER_COUNT = 1
FRONT_MODULES_TWITTER_LENGTH = 100
FRONT_MODULES_TWITTER_LINK_LENGTH = 50
FRONT_MODULES_BLOG_PUBLIC_COUNT = 2
FRONT_MODULES_BLOG_PUBLIC_LENGTH = 200

ON_THE_RADAR_FEED_LENGTH = 300
ON_THE_RADAR_WHITE_PAPER_COUNT = 3

MYFILES_TITLE_LENGTH = 50

SEARCH_PATH = "/projects/search"
SEARCH_FIELD = "q"
SEARCH_RESULT_LENGTH = 400
SEARCH_PAGINATION_COUNT = 20

REPORTING_START_DATE_STRING = "2010-01-01"  # YYYY-MM-DD
#REPORTING_START_YEAR = 2010
#REPORTING_START_MONTH = 1


#REPORTING_CATEGORIES = ['registration', 'subscription', 'search_term', 'repository_usage', 'checklist_usage','resource_usage', 'checklist_project','checklist_section','checklist_item']
#REPORTING_TITLES = {'registration' => 'Registered Users', 'subscription' => 'Subscription', 'search_term' => 'Search Term', 'repository_usage' => 'Repository Usage', 'checklist_usage' => 'Checklist Usage','resource_usage'=>'Resource Clicks', 'checklist_project' => 'Checklist Project Status', 'checklist_section' => 'Checklist Section Usage','checklist_item' => 'Checklist Items Usage'}

REPORTING_CATEGORIES = ['registration', 'search_term', 'repository_usage', 'checklist_usage','resource_usage', 'checklist_project','checklist_section','checklist_item', 'mentor']
REPORTING_TITLES = {'registration' => 'Registered Users', 'search_term' => 'Search Term', 'repository_usage' => 'Repository Usage', 'checklist_usage' => 'Checklist Usage','resource_usage'=>'Resource Clicks', 'checklist_project' => 'Checklist Project Status', 'checklist_section' => 'Checklist Section Usage','checklist_item' => 'Checklist Items Usage', 'mentor' => 'Mentors'}

MY_FILES_TEMPLATES_COUNT = 5

FRONT_MODULES_TWITTER_PUBLIC_COUNT = 4

MESSAGES_POPULAR_TOPICS_COUNT = 5

PAGINATION_MESSAGES_COUNT = 100

SITE_VIDEO_PATH_HOW_IT_WORKS = "/site_videos/wstart-howitworks_hq.flv"
SITE_VIDEO_PATH_GUIDED_TOURS = "/site_videos/guided-tours.flv"

SHOW_EXTRA_ADMIN_TASKS = false

# Contact_us_ NAME and EMAIL are recipient's info for contact_us's email
CONTACT_US_NAME  = "Workshop In Business Opportunities's Admin"
CONTACT_US_EMAIL = "wickedstart@ifelnj.org"
FROM_EMAIL = "Workshop In Business Opportunities <noreply@wibo.wickedstart.com>"
CONTACT_US_BCC_EMAIL = "Umer Farooq <mail.to.umerfarooq@gmail.com>"
COMMUNITY_EMAIL = "Umer Farooq <mail.to.umerfarooq@gmail.com>"
COMMUNITY_BCC_EMAIL = nil

# Static pages are static pages of the site. :)
#STATIC_PAGES = %w[privacy_policy terms_and_conditions]
#STATIC_PAGES = ['privacy_policy', 'terms_and_conditions']
#STATIC_PAGES = ['home', 'admin', 'privacy_policy', 'terms_and_conditions', 'header', 'footer', 'navigation', 'how_it_works', 'ten_steps', 'take_a_tour', 'google_analytics', 'four_o_four']
#STATIC_PAGES = ['home', 'admin', 'header', 'footer', 'navigation', 'how_it_works', 'ten_steps', 'take_a_tour', 'google_analytics','four_o_four']
STATIC_PAGES = ['home', 'admin', 'header', 'footer', 'navigation', 'how_it_works', 'take_a_tour', 'google_analytics','four_o_four']

#Domain Name:	wickedstartlocal.com
#ENV['RECAPTCHA_PUBLIC_KEY']  = '6Le1vwsAAAAAAD_l0RtC5eKP-1PJJf7OHFHJSOxf'
#ENV['RECAPTCHA_PRIVATE_KEY'] = '6Le1vwsAAAAAAHpwx5zbq8u-DKbUwfIRMX5EzRiw'
#Domain Name:	wickedstart.com GLOBAL for devtestrails@gmail.com
ENV['RECAPTCHA_PUBLIC_KEY']  = '6LcDvboSAAAAALnFsCjVccz8N6YfSVXjaLAjItMc'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LcDvboSAAAAAPMy6wEWbwwBaAMcifuMZMY2xzKt'

#Authlogic::ActsAsAuthentic::PerishableToken::Config.perishable_token_valid_for(24.hours)

# field_with_error_fix
ActionView::Base.field_error_proc = Proc.new { |html_tag, instance|
  "<span class=\"fieldWithErrors\">#{html_tag}</span>"
}

PUBLIC_KEY_FILE = File.join(File.dirname(__FILE__), '../public.pem')
PRIVATE_KEY_FILE = File.join(File.dirname(__FILE__), '../private.pem')

#config.after_initialize do
#  ActiveMerchant::Billing::Base.mode = :test
#  ::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
#    :login => "seller_1229899173_biz_api1.railscasts.com",
#    :password => "FXWU58S7KXFC6HBE",
#    :signature => "AGjv6SW.mTiKxtkm6L9DcSUCUgePAUDQ3L-kTdszkPG8mRfjaRZDYtSu"
#  )
#end

#AUTHORIZE_NET_CREDENTIALS = {:login =>  "Darlene@ivycapitaltechnologies.com", :password => "Wickedstart1", :test => 'true'}
#AUTHORIZE_NET_CREDENTIALS={:login =>  "8JY5yrDa8C",:password => "8y8hCDVyA5C73x4M", :test => 'true'}
AUTHORIZE_NET_REQUEST_URL = 'https://api.authorize.net/xml/v1/request.api'
AUTHORIZE_NET_ID = "88BUebw4Vy"
AUTHORIZE_NET_KEY = "828yV4sW879mS8b7"
AUTHORIZE_NET_CREDENTIALS={:login =>  "88BUebw4Vy",:password => "828yV4sW879mS8b7"}
REGISTRATION_AMOUNT = 49.99
RECURRING_AMOUNT = 9.99
REGISTRATION_AMOUNT_CENTS = 4999
RECURRING_AMOUNT_CENTS = 999

DEFAULT_PACKAGE = 'basic_package'

FILE_TYPE_PDF = %w[application/pdf application/x-pdf application/acrobat applications/vnd.pdf text/pdf text/x-pdf]
FILE_TYPE_IMAGE = %w[image/bmp image/cmu-raster image/fif image/florian image/g3fax image/gif image/ief image/jpeg image/jutvision image/naplps image/pict image/pjpeg image/png image/tiff image/vasa image/vnd.dwg image/vnd.fpx image/vnd.net-fpx image/vnd.rn-realflash image/vnd.rn-realpix image/vnd.wap.wbmp image/vnd.xiff image/xbm image/x-cmu-raster image/x-dwg image/x-icon image/x-jg image/x-jps image/x-niff image/x-pcx image/x-pict image/xpm image/x-portable-anymap image/x-portable-bitmap image/x-portable-graymap image/x-portable-greymap image/x-portable-pixmap image/x-quicktime image/x-rgb image/x-tiff image/x-windows-bmp image/x-xbitmap image/x-xbm image/x-xpixmap image/x-xwd image/x-xwindowdump]
FILE_TYPE_VIDEO = %w[video/x-flv]
FILE_TYPE_ZIP = %w[application/zip]

FILE_TYPE_WORD = %w[text/plain application/rtf application/x-rtf text/rtf text/richtext application/msword application/doc application/x-soffice application/msword application/vnd.ms-word.document.macroEnabled.12 application/vnd.openxmlformats-officedocument.wordprocessingml.document application/msword application/vnd.ms-word.template.macroEnabled.12 application/vnd.openxmlformats-officedocument.wordprocessingml.template]
FILE_TYPE_EXCEL = %w[application/vnd.ms-excel application/vnd.ms-excel.addin.macroEnabled.12 application/vnd.ms-excel application/vnd.ms-excel.sheet.binary.macroEnabled.12 application/vnd.ms-excel.sheet.macroEnabled.12 application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel application/vnd.ms-excel.template.macroEnabled.12 application/vnd.openxmlformats-officedocument.spreadsheetml.template]
FILE_TYPE_POWERPOINT = %w[application/vnd.ms-powerpoint application/vnd.ms-powerpoint.template.macroEnabled.12 application/vnd.openxmlformats-officedocument.presentationml.template application/vnd.ms-powerpoint.addin.macroEnabled.12 application/vnd.ms-powerpoint application/vnd.ms-powerpoint.slideshow.macroEnabled.12 application/vnd.openxmlformats-officedocument.presentationml.slideshow application/vnd.ms-powerpoint application/vnd.ms-powerpoint application/vnd.ms-powerpoint.presentation.macroEnabled.12 application/vnd.openxmlformats-officedocument.presentationml.presentation]
FILE_TYPE_PROJECT = %w[application/vnd.ms-project application/msproj application/msproject application/x-msproject application/x-ms-project application/x-dos_ms_project application/mpp zz-application/zz-winassoc-mpp]
FILE_TYPE_VISIO = %w[application/visio application/x-visio application/vnd.visio application/visio.drawing application/vsd application/x-vsd image/x-vsd zz-application/zz-winassoc-vsd]
FILE_TYPE_POWERPOINT_IRREGULAR = %w[application/vnd.word]
FILE_TYPE_ALL_OFFICE = FILE_TYPE_WORD + FILE_TYPE_EXCEL + FILE_TYPE_POWERPOINT + FILE_TYPE_PROJECT + FILE_TYPE_VISIO + FILE_TYPE_POWERPOINT_IRREGULAR

MAXSIZE_USER_DOCUMENT = 50.megabytes
FILE_TYPE_USER_DOCUMENT = FILE_TYPE_ALL_OFFICE + FILE_TYPE_PDF + FILE_TYPE_IMAGE
FILE_TYPE_CHART =FILE_TYPE_USER_DOCUMENT + FILE_TYPE_ZIP

OCCURRENCES = 9999
WEEKLY = 7
MONTHLY = 1
TRIAL_OCCURRENCES = 1

Mime::Type.register "application/vnd.ms-excel", :xls

SUBJECT_FOR_NEWSLETTER_SUBSCRIPTION = 'Newsletter subscription'
TEXT_FOR_NEWSLETTER_SUBSCRIPTION = 'Subscribe me for newsletters'
CONTACT_US_NEWSLETTER_REQUEST_FROM_VALUE = 'newsletter'

BIO_SUMMARY_LENGTH = 100
FEATURE_SUMMARY_LENGTH = 150
GET_SATISFACTION_PATH = 'http://getsatisfaction.com/wicked_start'