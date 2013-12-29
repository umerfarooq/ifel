ActionController::Routing::Routes.draw do |map|
  map.resources :registration_codes, :member => {:activate => :get, :inactivate => :get}

  map.resources :mentors, :member => {:activate => :get, :inactivate => :get, :publish => :get, :associate_user => :get, :update_user_association => :post}
  map.my_mentor 'my_mentor', :controller => :mentors, :action => :show

  map.resources :configurations, :collection => {:accounts => :get, :designs => :get}
  map.resources :news_providers
  map.resources :events_providers
  map.resources :community
  map.resources :community_question
  map.resources :dashboards, :collection => {:resource_category_filter=> :get,:cancel_notification_box => :put, :cancel_notification_banner=> :put,:cancel_progress_banner=>:put}, :member=>{:update_banner_notifications=>:put}
  map.dashboard 'dashboard', :controller => :dashboards, :action => :index


  ##  muzammil start
  #
  map.resources :companies,:collection=>{:company_profile=>:get,:upload_logo=>:post,:upload_mark=>:post}, :member=>{:update_company_content=>:put}
  map.company_profile 'company_profile', :controller => :companies, :action => :index
  map.upload_logo 'upload_logo/:id', :controller => :companies, :action => :upload_logo
  map.upload_mark 'upload_mark/:id', :controller => :companies, :action => :upload_mark
  map.track_resource 'resources/click/:resource_id/:user_id',:controller=>"resources",:action=>"track_resource"
  ## muzammil end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'

  map.alert 'static/blog_alert', :controller => 'static', :action => 'alert'

  #  map.about_us 'about_us', :controller => 'biographies', :action => 'index'
  #  map.how_it_works 'how_it_works', :controller => 'partners', :action => 'index'
  #
  #  map.public_home 'home', :controller => 'home', :action => 'public_home'
  #  map.public_home 'home', :controller => 'home', :action => 'show', :page => 'home'
  # TODO # ABDULLAH'S CODE  # TODO [8/10/10 8:33 PM] => EXTRA_THREE_LINES
  #  map.header_partial 'shared/header', :controller => 'bloglayout', :action => 'blog_header_partial'
  #  map.footer_partial 'shared/footer', :controller => 'bloglayout', :action => 'blog_footer_partial'
  #  map.navigation_partial 'shared/navigation', :controller => 'bloglayout', :action => 'blog_navigation_partial'
  # TODO # CHECK_IT

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  map.resources :messages, :collection => {:display_more_questions=>:get,:show_message_detail_page=>:get,:vote_message=>:get,:comment_inappropriate=>:get, :comment_appropriate=>:get,:topic_search=>:get,:question_nothelpful=>:get,:question_helpful=>:get, :create_comment=>:get,:update_message_body=>:get,:update_message_topics=> :get,:unfollow_question=>:get, :follow_question=>:get,:search => :get, :load_questions => :get}, :member=>{:update_post_question_content => :put, :edit_post_question_content => :get}
  map.feedwall 'feedwall', :controller => :messages, :action => :index
  map.community_profile 'community_profile', :controller=> :messages, :action => :community_profile
  map.topic_categories 'topic_categories', :controller=> :messages, :action => :topic_categories
  #  map.resources :users do |user|
  #    user.resources :messages, :collection => {:search => :get}#,:only => [:index]
  #  end
  #TODO USE NAMES ETC FOR RENAMING URLS
  map.resources :users,:member => {:update_profile_summary => :put, :update_tooltip => :put, :upload_picture => :post, :mark_as_employee => :put, :unmark_as_expert => :put, :assign_mentor => :put, :community_answers => :get, :email_mentor => :post, :block_or_unblock => :put, :dissociate_mentor => :put, :update_experted_sections => :put}, :collection => {:login_available => [:get, :post], :search => :get, :roles => :get}, :has_one => :credential
  map.guidance 'guidance', :controller => :users, :action => :guidance
  map.profile 'profile', :controller => :users, :action => :edit
  map.resources :credentials, :collection => {:cancel_subscription => [:get]}
  map.resource  :user_session, :only => [:new, :create, :destroy]

  map.resources :success_stories, :collection => {:list => [:get]}, :member => {:activate => :get, :inactivate => :get, :publish => :get, :featurify => :get, :move_up => :get, :move_down => :get}
  #  map.resources :biographies, :collection => {:list => :get, :flvplayer => [:get]}, :member => {:activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get}
  map.resources :news_providers, :member => {:activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get}
  map.resources :events_providers, :member => {:activate => :get, :inactivate => :get, :publish => :get}
  map.resources :news_items, :only => [:index, :show, :new, :create, :change_state, :edit], :collection => {:change_state => [:get]}

  map.resources :news_articles, :collection => {:list => [:get]}, :member => {:display => :get, :activate => :get, :inactivate => :get, :publish => :get, :featurify => :get}
  map.resources :white_papers, :member => {:activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get}
  map.connect   "white_papers/:id/:filename", :controller => 'white_papers', :action => 'download', :conditions => { :method => :get }, :requirements => { :filename => /.*/ }
  #  map.resources :quizzes, :only => [:new, :create, :change_state]
  #  map.resources :partners, :only => [:index, :new, :create, :edit, :update, :destroy, :change_state], :collection => {:change_state => [:get]}
  map.resources :partners, :collection => {:list => :get, :become_partner_request => :any}, :member => {:activate => :get, :inactivate => :get, :publish => :get}

  map.resources :faqs, :only => [:index, :new, :create, :edit, :update, :destroy, :change_state], :collection => {:change_state => [:get]}, :member => {:activate => :get, :inactivate => :get, :publish => :get}
  map.resources :industries, :member => {:activate => :get, :inactivate => :get, :publish => :get}

  map.resource  :contact_us, :collection => {:thanks => :get, :reply => :get, :create => :any}, :member => {:subscribe_for_news_letters => :get}
  ##############################################################################
  # map.INTERNAL_ALPHA-ROUTES
  ##############################################################################
  #  map.resources :projects, :has_many => [:sections, :documents], :collection => {:search => [:get],:congratulation=>:get , :guidance => [:get]}, :member => {:summary => :get}
  map.resources :projects, :has_many => :sections, :collection => {:search => :get, :congratulation => :get, :guidance => :get, :hide_overdue_notice => :post, :close_dock_help => :put, :add_todo => :post, :print_roadmap_steps => :post}, :member => {:summary => :get, :overview => :get, :print => :get, :set_opened_section => :any, :update_answer => :put, :update_contents => :put}
  map.roadmap 'roadmap', :controller => :projects, :action => :show
  #  map.resources :sections, :collection =>{:change_section_view => [:get]}
  #  map.resources :sections, :has_many => :items ,:collection =>{:change_section_view => [:get], :print => [:get]}, :member => { :introduction => :get, :update_due_date => :put, :mark_show_intro => :put, :display => :get }
  map.resources :sections, :has_many => :items, :collection=>{:flvplayer => [:get]}, :member => { :introduction => :get, :overview => :get, :update_due_date => :put, :mark_show_intro => :put, :display => :get, :print => :get, :update_answer => :put, :update_deadline => :put, :print_notes => :get }

  map.resources :examples, :only => [:new, :create], :member => {:download => :get}
  #  map.resources :template_documents, :only => [:new, :create]
  map.resources :template_documents, :member => {:activate => :get, :inactivate => :get, :publish => :get, :featurify => :get, :download => :get}
  map.resources :templates, :controller => :template_documents, :only => :index

  #  map.resources :item_templates, :only => [:index, :show] do |item_template|
  map.resources :section_templates, :member => {:activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get, :synchronize => :get, :download => :get}, :collection =>{:overview => :get} do |section_template|
    section_template.resources :item_templates
  end
  map.resources :item_templates, :member => {:activate => :get, :inactivate => :get, :publish => :get, :toggle_example_type => :get, :move_up => :get, :move_down => :get, :synchronize => :get} do |item_template|
    item_template.resources :examples, :member => { :activate => :get, :inactivate => :get, :publish => :get}
    item_template.resources :templatifications, :member => {:publish => :get}
    item_template.resources :resourcifications, :member => {:publish => :get}
  end

  #TODO # remove download # 7/13/10 8:17 PM
  map.resources :items,:has_many => :notes, :member => { :download => :get, :add_file => :post, :mark_complete => :put, :mark_not_applicable => :put , :update_answer => :put, :display => :get, :print => :get, :open_section_item => :get, :get_resources => :get, :is_file_exist => :get, :add_note => :post, :post_question_to_community => :post }, :collection => {}

  map.resources :resource_categories, :collection => {:list => [:get]}, :member => {:activate => :get, :inactivate => :get, :publish => :get, :summary => :get, :update_summary => :put, :edit_content_message => :get, :update_content_message => :put, :edit_resource_message => :get, :update_resource_message => :put}
  map.resources :template_categories, :collection => {:list => [:get]}, :member => {:activate => :get, :inactivate => :get, :publish => :get} do |template_category|
    template_category.resources :templates, :controller => :template_documents, :only => :index
  end

  map.resources :faq_categories, :member => {:activate => :get, :inactivate => :get, :publish => :get}
  
  map.resources :resources, :collection => {:display_more_service_providers=> :get,:resource_library => [:get], :service_provider => [:get], :submit_resource => :post, :load_all_tags=>:get,:load_more_resources=>:get, :title => :get, :list => :get }, :member => {:activate => :get, :inactivate => :get, :publish => :get, :load_resource_section_content => :get, :load_service_section_content => :get, :load_all_content => :get, :load_category_content => :get, :edit_service => :get, :show_comments => :get, :add_comments => :any, :thumbs_up => :any, :thumbs_down => :any,:remove_image=>:put,:remove_banner=>:put, :edit_content_message => :get, :update_content_message => :put}
  #  map.load_section_category_content "/resources/load_section_category_content/:category_id/:section_id", :controller => 'resources', :action => 'load_section_category_content', :conditions => { :method => :get }
  #  map.load_section_category_content "/resources/load_section_category_content/:category_id", :controller => 'resources', :action => 'load_section_category_content', :conditions => { :method => :get }
  #  map.load_right_category_content "/resources/load_right_category_content/:category_id/:section_id", :controller => 'resources', :action => 'load_right_category_content', :conditions => { :method => :get }
  #  map.load_right_category_content "/resources/load_right_category_content/:category_id", :controller => 'resources', :action => 'load_right_category_content', :conditions => { :method => :get }
  #  map.load_tag_content "/resources/load_tag_content/:tag_id/:is_resource_library/:is_top_tag/:section_id", :controller => 'resources', :action => 'load_tag_content', :conditions => { :method => :get }
  #  map.load_tag_content "/resources/load_tag_content/:tag_id/:is_resource_library/:is_top_tag", :controller => 'resources', :action => 'load_tag_content', :conditions => { :method => :get }
  map.load_tag_content "/resources/load_tag_content/:tag_id", :controller => 'resources', :action => 'load_tag_content', :conditions => { :method => :get }
  #  map.load_all_content "/resources//load_all_content/", :controller => 'resources', :action => 'load_all_content', :conditions => { :method => :get }
  #  map.sorting "/resources/sorting/:is_resource_sorting", :controller => 'resources', :action => 'sorting', :conditions => { :method => :get }

  
  map.resources :documents, :collection => {:list => :get, :list_documents => :get,:search => :get, :is_file_exist => :post, :share_document => :post}, :member => { :update_contents => :post, :download => :get, :show_section_templates => :get, :update_file_content => :put, :upload_document_to_section => :post, :replace_document  => :put }  # TODO [8/11/10 5:06 AM] => REVISIT_THIS_IMP-

  map.resources :admins, :collection => {:home_page_tab => [:get], :launch_pad_tab => [:get], :community_tab => [:get], :files_tab => [:get], :resources_tab => [:get], :radar_tab => [:get], :inspiration_tab => [:get], :about_us_tab => [:get], :partners_tab => [:get], :faqs_tab => [:get], :billing_tab => [:get], :reporting_tab => [:get], :quizzes_tab => [:get], :features_tab => [:get], :common_questions_tab => [:get], :industry_tab => [:get], :content_tab => [:get], :my_files_tab => :get, :roadmap_tab => :get, :dashboard_tab => [:get], :company_tab => [:get]}
  map.resources :marketing_text_messages, :collection => {:edit_post_message_content => :get, :update_post_message_content => :any }, :member => { :edit_post_message_content => :get, :update_post_message_content => :any}
  map.resources :marketing_multimedia_messages, :as => "multimedia", :collection => {:play => :get}

  #  map.resources :messages, :member => { :comment => :get }
  #  map.resources :messages, :has_many => :comments, :member => { :confirmation => :get }
  #  map.resources :messages, :collection => { :category => :get }, :member => { :confirmation => :get, :inappropriate => [:get, :post] } do |message|
  #  map.resources :messages, :member => { :confirmation => :get, :report_abuse => [:get, :post], :thumbsup => :get, :thumbsdown => :get } do |message|
  map.resources :messages, :collection => { :popular => :get,:update_message_body=>:get, :for_staff => :get }, :member => { :confirmation => :get, :report_abuse => [:get, :post], :thumbsup => :get, :thumbsdown => :get } do |message|
    message.resources :comments, :member => { :confirmation => :get, :report_abuse => [:get, :post], :thumbsup => [:get, :post], :thumbsdown => [:get, :post] }
  end
  map.resources :inappropriates
  map.resources :message_categories, :only => [:index] do |message_category|
    message_category.resources :messages, :only => [:index]
  end

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  map.resources :passwords, :collection => { :forget => :get }, :member => { :change => :get }, :only => [:forget, :create, :show, :change, :update]

  #  map.resources :message_categories, :collection => {:change_state => [:get]}
  map.resources :message_categories, :collection => {:list => :get}, :member => {:activate => :get, :inactivate => :get, :publish => :get}
  
  map.resources :topics, :collection =>{:change_state => [:get],:topic_items_on_category=>:get, :create_orphan_topic=>[:any],:list => :get, :select_topic_on_item=>:get, :select_topic_on_section=>:get}, :member => {:activate => :get, :inactivate => :get, :publish => :get, :activate_template => :put, :inactivate_template => :put, :publish_template => :put, :activate_orphan_topic=>:get, :activate_orphan=>[:any], :mark_template_as_default => :put, :unmark_template_as_default => :put}

  map.resources :document_categories, :collection => {:list => :get}, :member => {:activate => :get, :inactivate => :get, :publish => :get}
  map.resources :news_categories, :collection => {:change_state => [:get]}

  map.resources :event_categories, :member => { :activate => :get, :inactivate => :get, :publish => :get}, :except => [:index,  :show]

  map.resources :silent_posts, :collection => {:make => [:post,:get]}
  map.resources :promo_codes
  #  map.resources :reports, :collection => {:registration => [:get, :post], :subscription => [:get, :post], :search_term => [:get, :post], :repository_usage => [:get, :post], :checklist_usage => [:get, :post]}
  map.resources :reports, :path_prefix => '/report_category/:report_category', :requirements => { :report_category => Regexp.new(REPORTING_CATEGORIES.join('|')), :id => /\d{4}-\d{2}/ }, :collection => {:adhoc => :post}, :only => [:index, :show]
  map.report_list 'reports', :controller => 'reports', :action => 'index'
  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  #  map.root :controller => 'home', :action => 'public_home'
  map.root :controller => 'home', :action => 'show', :page => 'home'
  map.home ':page', :controller => 'home', :action => 'show', :page => Regexp.new(STATIC_PAGES.join('|'))

  map.home_page 'home_page', :controller => 'home', :action => 'index'
  map.guided_tour_video 'guided_tour_video', :controller => :home, :action => :guided_tour_video

  map.with_options :controller => 'info' do |info|
    info.public_home 'public_home', :action => 'public_home'
    info.about_us 'about_us', :action => 'about_us'
    info.search 'search', :action => 'search'
    info.privacy_policy 'privacy_policy', :action => 'privacy_policy'
    info.terms_and_conditions 'terms_and_conditions', :action => 'terms_and_conditions'
    info.comming_soon 'comming_soon', :action => 'comming_soon'
    info.ten_steps 'ten_steps', :action => 'ten_steps'
    info.questionnaire 'questionnaire', :action => 'questionnaire'
    info.community_guidelines 'community_guidelines', :action => 'community_guidelines'
  end

  map.resources :quiz_replies, :only => [:new, :create], :member => {:thanks => :get}

  map.quiz_reply_for ':quiz_path', :controller => 'quiz_replies', :action => 'new', :quiz_path => QuizReply::ROUTES_REGEX

  map.resources :quizzes, :member => {:activate => :get, :inactivate => :get, :publish => :get} do |quiz|
    quiz.resources :questions, :only => ['new', 'create', 'edit', 'update']
  end
  map.resources :questions, :only => ['show'], :member => {:activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get}

  map.resources :biographies, :collection => {:list => :get, :flvplayer => [:get]}, :member => {:play => :get, :display => :get, :activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get} do |biography|
    biography.resources :biography_links, :only => ['new', 'create', 'edit', 'update']
  end
  map.resources :biography_links, :only => ['show'], :member => {:activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get}

  map.resources :events, :collection => {:list => :get, :pull_feeds => :get}, :member => {:display => :get, :activate => :get, :inactivate => :get, :publish => :get, :featurify => :get}
  map.resources :promotions, :collection => {:list => :get}, :member => {:display => :get, :activate => :get, :inactivate => :get, :publish => :get, :featurify => :get, :update_promotion_box => :any}, :except => [:index,  :show]

  map.resources :features, :collection => {:list => :get, :flvplayer => [:get], :pricing => [:get], :why_wicked_start => [:get]}, :member => {:display => :get, :activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get, :detail => :get}

  map.resources :common_questions, :member =>{:display => :get, :activate => :get, :inactivate => :get, :publish => :get, :move_up => :get, :move_down => :get, :detail => :get}, :collection => {:list => :get, :flvplayer => :get, :have_a_question => :any}
  map.refresh_all_sliders "/common_questions/refresh_all_sliders/:id", :controller => "common_questions", :action => "refresh_all_sliders"
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #  map.connect ':controller/:action/:id'
  #  map.connect ':controller/:action/:id.:format'
  map.sitemap "sitemap", :controller => 'home', :action => 'sitemap'
  map.four_o_four "*e", :controller => "home", :action => "show", :page => "four_o_four" unless Rails.env.development?

  #  map.resources :dashboards, :collection => {:resource_category_filter=> :get,:cancel_notification_box => :put, :cancel_notification_banner=> :put,:cancel_progress_banner=>:put}, :member=>{:update_banner_notifications=>:put}
  map.dashboard 'dashboard', :controller => :dashboards, :action => :index
  
  Jammit::Routes.draw(map)
end