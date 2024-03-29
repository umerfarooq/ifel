# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION
require 'thread'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  #config.gem "pauldix-feedzirra", :lib => "feedzirra", :source => "http://gems.github.com"
  config.gem "ambethia-recaptcha", :lib => "recaptcha/rails", :source => "http://gems.github.com"
  config.gem 'authlogic', :version => '~> 2.1.6'
  config.gem 'will_paginate', :version => '~> 2.3.12', :source => 'http://gemcutter.org'
  #  config.gem "activemerchant", :lib => "active_merchant", :version => "1.4.1"
  config.gem 'activemerchant', :lib => 'active_merchant', :version => '1.5.1'
  config.gem "validates_existence", :source => "http://rubygems.org"
  config.gem "carmen", :source => 'http://gemcutter.org'
  config.gem "aws-s3", :lib => 'aws/s3'
  config.gem 'chronic'
  config.gem 'javan-whenever', :lib => false, :source => 'http://gems.github.com'
  config.gem "ghazel-daemons", :lib => "daemons"
  #  gem "ghazel-daemons"
  #  require "daemons"
  config.gem 'delayed_job', :version => '~> 2.0.7'
  config.gem 'cancan'

  config.gem 'feedvalidator', :lib => "feed_validator"
  config.gem 'simple_xlsx_writer', :lib => "simple_xlsx"
  config.gem 'htmlentities'
  config.gem "jammit"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #  config.time_zone = 'UTC'
  config.time_zone = 'Eastern Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  require 'pdfkit'
end
#require "will_paginate"

#require "custom_logger"
