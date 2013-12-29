class ItemsController < ApplicationController
  before_filter :require_user
  before_filter :require_payment
  before_filter { |c| c.active_tab=:launch_list }
  before_filter :load_content, :only=>:show
  protect_from_forgery :except => [:add_file]

  #  # TODO ? # TODO [10/8/10 4:48 PM] => DELETE_CODE : EXTRA FUNCTIONS
  #  def new
  #  end
  #
  #  # TODO ? # TODO [10/8/10 4:48 PM] => DELETE_CODE : EXTRA FUNCTIONS
  #  def create
  #  end
  #
  #  # TODO ? # TODO [10/8/10 4:48 PM] => DELETE_CODE : EXTRA FUNCTIONS
  #  def index
  #    @sections = @current_user.project.sections.all_active
  ##    @sections = Section.all_active
  #    @items = @current_user.project.items.all_active
  ##    @items = Item.all_active
  #  end

  #   # TODO [10/11/10 7:39 PM] => REFACTOR EDIT <=> SHOW
  #  def edit               # MOVED TO ITEM.SHOW
  #     # TODO [10/20/10 8:33 PM] => ADD IS VIEWED CODE
  ##    enable_light_box
  #    @item = @current_user.project.items.find params[:id]
  ##    @item.section.project.update_attribute(:open_section, @item.section_id)
  #    return redirect_to introduction_section_path(@item.section) unless @item.section.is_intro_viewed
  #    if @item.preceding.class.to_s == "Section"
  #      if @item.preceding.do_show_intro
  #        @preceding = introduction_section_path(@item.preceding)
  #      else
  #        @preceding = edit_item_path(@item.preceding.preceding)
  #      end
  #    else
  #      @preceding = edit_item_path(@item.preceding)
  #    end
  #    if @item.following.class.to_s == "Section"
  #      if @item.following.do_show_intro
  #        @following = introduction_section_path(@item.following)
  #      else
  #        @following = edit_item_path(@item.following.following)
  #      end
  #    else
  #      @following = edit_item_path(@item.following)
  #    end
  #    @item.reviewed!
  #    render :layout => false
  #  end

  # TODO [11/9/10 4:36 PM] => REFACTOR_ITEM_SECTION_NAVIGATION_FOR_NEXT_AND_PREVIOUS
  def show_old
    #    enable_light_box
    @item = @current_user.project.items.find params[:id]
    #@item.section.project.update_attribute(:open_section, @item.section_id)  # @item.reviewd!
    return redirect_to introduction_section_path(@item.section) unless @item.section.is_intro_viewed
    if @item.preceding.class == Section
      if @item.preceding.do_show_intro
        @preceding = introduction_section_path(@item.preceding)
      else
        @preceding = item_path(@item.preceding.preceding)
      end
    else
      @preceding = item_path(@item.preceding)
    end
    if @item.following.class == Section
      if @item.following.do_show_intro
        @following = introduction_section_path(@item.following)
      else
        @following = item_path(@item.following.following)
      end
    else
      @following = item_path(@item.following)
    end
    @item.reviewed!
    render :layout => false
  end

  #  def open_section_item
  def show
    @item = Item.find(params[:id].to_i)
    if params[:current_item_id].present?
      @active_item = Item.find(params[:current_item_id].to_i)
      @active_item.update_attribute(:user_answer, params[:item_user_answer])
    end
       
    #    @item.update_attribute(:is_viewed, true)
    @item.is_viewed = true
    @item.save(false)
    load_community_activity
    return render :partial => 'item_detail', :locals=>{:item=>@item}
  end

  def get_resources
    item = Item.find(params[:id].to_i)
    case params[:type]
    when 'files'
      return render :partial => 'dock_file_panel', :locals => {:documents => item.documents.date_wise}
    when 'resources'
      return render :partial => 'dock_resource_panel', :locals => {:resources => item.item_template.resources.published.date_wise, :section => item.section }
    when 'templates'
      templates = item.item_template.template_documents
      return render :partial => 'dock_template_panel', :locals => {:templates => (templates.published.date_wise + templates.featurified.date_wise) }
    when 'notes'
      return render :partial => 'dock_note_panel', :locals => {:notes => item.notes.date_wise}
    when 'examples'
      templates = item.item_template.template_documents
      return render :partial => 'dock_example_panel', :locals => {:examples => item.item_template.examples.published.date_wise, :templates => (templates.published.date_wise + templates.featurified.date_wise)}
    end
  end

  def add_note
    item = Item.find(params[:id].to_i)
    if item.notes.create(:description => params[:description].to_s)
      item.section.project.set_opened_section(item.section.id)
      return render :partial => 'dock_note_panel', :locals => {:notes => item.notes.date_wise}
    end
  end

  def post_question_to_community
    item = Item.find(params[:id])
    default_section_id = item.section.section_template.id.to_s
    params[:message][:item_template_id] = item.item_template_id
    message = Message.create_message(params,@current_user)
    if message
      item.section.project.set_opened_section(item.section.id)
      #send an email to share message here
      return render :text => {:question_posted=>true, :default_section_id => default_section_id}.to_json
    else
      return render :text => {:question_posted=>false, :errors=>message.errors}.to_json
    end
  end

  #  def update  # TODO [11/2/10 2:40 AM] => REMOVE_CODE
  #    RAILS_DEFAULT_LOGGER.debug "__CHECK__ITEMS_CONTROLLER__UPDATE__ENTER__"
  ##    @item = @current_user.project.items.find params[:id]
  #    @item = @current_user.project.items.find params[:id]
  ##    @item = Item.find params[:id]
  ##    TODO # REMOVE UPLOAD FILE CODE AFTER TESTING
  ##    if(@item.has_upload && params[:userfile])
  ##      RAILS_DEFAULT_LOGGER.debug "__CHECK__ITEMS_CONTROLLER__UPDATE__FILE_UPLOAD_REQUEST__"
  ##      d = @item.documents.build(:data => params[:userfile])
  ##      d.documentable = @item
  ##      # TODO # REFACTOR CATEGORY
  ###      d.document_category = DocumentCategory.find @item.section.sequence_number
  ###      d.project_id = @item.section.project_id
  ##      RAILS_DEFAULT_LOGGER.debug "__#{d.inspect}__"
  ##    end
  ##    if params[:userfile].blank?
  #      @item.user_answer = params[:item][:user_answer]
  #      @item.is_complete = (params[:item][:is_complete] == "1")
  #      @item.is_not_applicable = (params[:item][:is_not_applicable] == "1")
  ##    end
  #    if @item.save
  #      RAILS_DEFAULT_LOGGER.debug "__CHECK__ITEMS_CONTROLLER__UPDATE__ITEM_SAVED__"
  #      #      flash[:notice] = "Item updated successfully."
  ##      if params[:userfile].blank?
  ##        render :text => @item.to_json(:only => [:is_complete, :user_answer], :methods => :is_not_applicable)
  ##      else
  ##        render :text => @item.documents.to_json(:only => [:data_file_name, :id, :item_id])
  #        render :text => @item.documents.latest.to_json(:only => [:data_file_name, :id, :item_id])
  ##      end
  #    else
  #      RAILS_DEFAULT_LOGGER.debug "__CHECK__ITEMS_CONTROLLER__UPDATE__ITEM_NOT_SAVED__"
  ##      return render :text => "" unless params[:userfile].blank?
  #      render :action => 'edit'
  #    end
  #  end 03318436634

  #    TODO 7/15/10 6:52 PM # REFACTOR AUTHORIZATION
  #    TODO 7/15/10 6:52 PM # AJAX ERROR MESSAGING
  #    TODO 7/15/10 6:52 PM # RECHECK CSRF AND AUTHENTICITY TOKEN (JS :=> AUTH_TOKEN)
  def update_answer
    @item = Item.find params[:id]
    unless @item.blank?
      if @item.update_attribute(:user_answer, params[:item_user_answer])
        @section = @item.section
        @section.project.set_opened_section(@item.section.id)
                
        # Read ERB File  
        content = File.read("#{Rails.root.to_s}/app/views/sections/print_notes_pdf.html.erb")  
        # Create new ERB template by passing required variable  
        template = ERB.new(content)  
        # Create new object to PDFKIt  
        kit = PDFKit.new(template.result(binding))  
        # Create Notes directory for this Item, If it doesn't already exists   
        dir_path = "#{Rails.root.to_s}/public/client/documents/notes/#{@section.id.to_s}"
        unless File.directory?(dir_path)
          FileUtils.mkdir_p(dir_path, :mode => 0777)
        end
        # Save this PDF
        file_name = "#{@section.title.concat(' notes').upcase.gsub(' ','-')}.pdf"
        file_path=File.join(dir_path, file_name)  
        kit.to_file(file_path)
        # Grab Item's Note Document and Update it with new file If exists, or create new one
        note_document = @section.self_documents.find_by_is_note(true)
        if note_document
          note_document.update_attribute(:data, File.open(file_path))
        else
          @section.self_documents.create({:data=>File.open(file_path), :is_note=>true})
        end
        
        return render :json => {:success => true, :item_user_answer => @item.user_answer}
      end
    end
    return render :json => {:success => false}
  end

  def mark_complete
    #    item = @current_user.project.items.find params[:id]
    #    item.update_attribute(:is_complete, (params[:item_is_complete] == "1"))
    #    item.update_attribute(:is_not_applicable, false) if item.is_complete
    #    return render :json => {:success => true, :item_is_complete => item.is_complete, :item_is_not_applicable => item.is_not_applicable}
    show_popup = false
    item = Item.find(params[:id])
    section = item.section
    if item.mark_as_complete params
      section.project.set_opened_section(item.section.id)
#      if section.is_first_section? and section.ended?
#        show_popup = true
#        UserMailer.deliver_email_after_step1_ended @current_user
#      end      
      html = render_to_string(:partial => "/items/item_status_panel.html.erb", :locals => {:item => item})
      return render :text => {:updated => true, :html => html, :show_popup => show_popup}.to_json
    else
      return render :text => {:updated => false}.to_json
    end
  end


  def mark_not_applicable
    #    item = @current_user.project.items.find params[:id]
    #    item.update_attribute(:is_not_applicable, (params[:item_is_not_applicable] == "1"))
    #    item.update_attribute(:is_complete, false) if item.is_not_applicable
    #    return render :json => {:success => true, :item_is_complete => item.is_complete, :item_is_not_applicable => item.is_not_applicable}
    show_popup = false
    item = Item.find(params[:id])
    section = item.section
    if item.mark_as_not_applicable params
      section.project.set_opened_section(item.section.id)
      if section.is_first_section? and section.ended?
        show_popup = true
        UserMailer.deliver_email_after_step1_ended @current_user
      end
      html = render_to_string(:partial => "/items/item_status_panel.html.erb", :locals => {:item => item})
      return render :text => {:updated => true, :html => html, :show_popup => show_popup}.to_json
    else
      return render :text => {:updated => false}.to_json
    end    
  end

  def add_file
    #    item = @current_user.project.items.find params[:id]
    item = Item.find(params[:id].to_s)
    doc = item.documents.build(:data => params[:userfile])
    if item.save
      item.section.project.set_opened_section(item.section.id)
      return render :text => {:success => true,:message => "File Has Been Uploaded", :document => item.documents.latest.first.as_json(:only => [:data_file_name, :id, :documentable_id])}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => doc.errors.as_json}.to_json
    end
  end

  def is_file_exist
    item = Item.find(params[:id].to_i)
    document = item.documents.find_by_data_file_name(params[:file].to_s)
    if document
      return render :text => {:file_exists => true, :document_id => document.id.to_s}.to_json
    else
      return render :text => {:file_exists => false}.to_json
    end
  end

  def display
    item = @current_user.project.items.find_by_id params[:id]
    if item.blank?
      flash[:error] = "The item you requested could not be found in your project."
      return redirect_to @current_user.project
      return render :text => "item not found"
    else
      return redirect_to(:controller => 'projects', :action => 'show', :id => @current_user.project.id, :display_item => item.id)
      return redirect_to(@current_user.project, :display_item => item.id)
    end
  end

  def print
    item = Item.find params[:id]
    @section = item.section
    render :layout => false
  end


  #  # TODO : MOVED TO DOCUMENTS CONTROLLER  # TODO [11/2/10 2:40 AM] => REMOVE_CODE
  #  def download_bak
  #    #http://thewebfellas.com/blog/2009/8/29/protecting-your-paperclip-downloads
  #    @item = Item.find params[:id];
  ##    @item = Item.find params[:id];
  #    @doc = Document.find params[:doc]
  #    #    return render :text => [@doc.to_json, @doc.url, @doc.path]
  #    if @doc && @doc.item_id == @item.id
  ##      send_file @doc.path, :type => @doc.content_type, :x_sendfile => true
  #      send_file @doc.path
  #      #      send_file @doc.path, :type => @doc.content_type, :disposition => 'inline', :x_sendfile => true
  #    else
  #      flash[:notice] = "Document not Found!"
  #      render :action => 'edit'
  #    end
  #  end

  private
  def load_content
    @item_contents = MarketingTextMessage.get_roadmap_contents
    @post_question_summary = MarketingTextMessage.find_by_page_and_location("messages", "post_question")
    @section_templates = SectionTemplate.published
  end
  def load_community_activity
    #    @community_activities= Message.community_activity_topic_recent_msgs(@item.item_template_id) + Message.community_activity_sections_recent_msgs(@item.item_template_id)
    @community_activities=Message.most_recent_and_similar_tagged_activities(@item.item_template_id)
    if @community_activities.blank?
      @community_activities=Message.most_recent_section_template_activities(@item.section.section_template_id)
    end
  end
end
