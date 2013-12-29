namespace :ws_data_script do
  desc "Script to move Business Ingredients to Users"
  task :migrate_data => :environment do
    RAILS_DEFAULT_LOGGER.info "--------------------Migrating Data----------------------"
    WsDataScripts.script_to_import_business_ingredients_from_projects_to_users
  end
  
  desc "Script to move Message IDs in Comments to Polymorphic Fields"
  task :migrate_message_ids => :environment do
    RAILS_DEFAULT_LOGGER.info "--------------------Migrating Data----------------------"
    WsDataScripts.script_to_move_message_id_from_comments_to_polymorphic_fields
  end

  desc "Script to migrate Document Filenames to Name field"
  task :migrate_document_filename => :environment do
    RAILS_DEFAULT_LOGGER.info "--------------------Migrating Data----------------------"
    WsDataScripts.script_to_populate_name_from_filename_in_documents
  end
  
  desc "Script to set Default document state as In Progress"
  task :set_default_document_state => :environment do
    RAILS_DEFAULT_LOGGER.info "--------------------Migrating Data----------------------"
    WsDataScripts.script_to_mark_documents_as_inprogress_as_default
  end

  desc "Mark previous comments as viewd"
  task :mark_comments_viewed => :environment do
    RAILS_DEFAULT_LOGGER.info "Marking comments Viewed"
    Message.all.each do |msg|
      msg.comments.each do |comment|
        comment.update_attribute(:is_new, 0)
      end
    end
  end

  desc "Mark latest comment of message as new"
  task :mark_comment_new => :environment do
    RAILS_DEFAULT_LOGGER.info "Marking comment New"
    Rake::Task['ws_data_script:mark_comments_viewed'].invoke
    Message.all.each do |msg|
      if !msg.comments.blank?
        msg.comments.last.update_attribute(:is_new, 1)
      end
    end
  end
  
end

namespace :ws_data_fixing_script do
  desc "Script to Create Project for a User (id=1958) whose Project wasn't created somehow"
  task :create_project => :environment do
    RAILS_DEFAULT_LOGGER.info "--------------------Creating Project----------------------"
    WsDataFixingScripts.create_users_project
  end
end