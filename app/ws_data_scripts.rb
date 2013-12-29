class WsDataScripts < ActiveRecord::Base

  def self.script_to_move_all_users_to_basic_package
    puts "Moving users to Package: #{DEFAULT_PACKAGE}"
    promo = PromoCode.find_by_code(DEFAULT_PACKAGE)
    puts "Gonna move all Users"
    User.all.each do |user|
      user.update_attribute(:promo_code_id, promo.id)
    end
    puts "All Users moved"

    puts "Altering Credentials"
    Credential.all.each do |cred|
      cred.update_attribute(:transaction_id,'free_account')
      cred.update_attribute(:billing_date,(Date.today+1000.years).to_s(:db))
      cred.update_attribute(:amount,0)
    end
    puts "All credentials altered"
  end

  def self.script_to_import_business_ingredients_from_projects_to_users
    User.all.each do |user|
      unless user.project.blank?
        business_name = user.project.business_name.to_s
        start_date = user.project.start_date
        end_date = user.project.end_date rescue nil
        planning_days = user.project.max_days rescue nil
      else
        business_name = 'Unspecified'
        start_date = user.registration_date
        end_date = nil
        planning_days = nil
        
        project = Project.new({:business_name => business_name, :start_date => start_date, :max_days => 0 })
        project.user = user
        project.save

      end
      user.update_attribute(:business_idea, business_name)
      user.update_attribute(:startup_process_start_date,start_date)
      user.update_attribute(:planning_days,planning_days)
      user.update_attribute(:startup_process_end_date,end_date)
    end
  end

  def self.script_to_move_message_id_from_comments_to_polymorphic_fields
    Comment.all.each do |comment|
      comment.update_attribute(:commentable_id, comment.message_id)
      comment.update_attribute(:commentable_type, 'Message')
    end
  end

  def self.script_to_populate_name_from_filename_in_documents
    Document.all.each do |doc|
      if doc.data_file_name
        splitted_filename = doc.data_file_name.split('.')
        filename = splitted_filename[0]
        doc.update_attribute(:name, filename)
      else
        doc.update_attribute(:name, 'Unspecified')
      end
    end
  end

  def self.script_to_mark_documents_as_inprogress_as_default
    Document.all.each do|doc|
      doc.update_attribute(:state, State.inprogress)
    end
  end
  
  def self.script_to_register_all_users_with_forum
    User.all.each do |user|
      next if user.id.to_i == 1
      forum_user = ForumAccount.new
      forum_user.register_user({:username=>user.login, :password=>'123456', :email=>user.email})  
    end    
  end
  
  def self.script_to_copy_resource_title_to_url_mask
    Resource.all.each do |res|
      res.update_attribute(:url_mask, res.title)        
    end
  end
  def self.script_to_move_usernames_to_screen_names
    User.all.each do |user|
      user.update_attribute(:screen_name, user.login)
    end
  end
  
  def self.script_to_dump_ifel_based_sections
    SectionTemplate.wibo.each_with_index do |template, index|
      ifel_template = template.clone
      ifel_template.associated_with = 'ifel'
#      ifel_template.item_templates << template.item_templates
      ifel_template.send(:create_without_callbacks)    
    end
  end
  
  def self.script_to_dump_ifel_based_items
    SectionTemplate.wibo.each_with_index do |template, index|
      ifel_template = SectionTemplate.ifel[index]
      
      template.item_templates.each do |item_template|
        ifel_item = item_template.clone
        ifel_item.section_template = ifel_template
        ifel_item.send(:create_without_callbacks)       
      end
      
    end
  end
  
end
