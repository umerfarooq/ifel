class DocumentsController < ApplicationController
  before_filter :require_user
  before_filter :require_payment
#  before_filter { |c| c.active_tab=:my_files }
  before_filter { |c| c.active_tab=:startup_workspace }
  before_filter :set_new_design_theme, :only => [:index]
  before_filter :load_content, :load_sections
  protect_from_forgery :except => [:upload_document_to_section]

  def index
    @editable_document = params[:edit] if params[:edit].present?
  end

  def new
    @document = Document.new
    render :layout => false
  end

  def create
    @document = Document.new(params[:document])
    #    @document.documentable = params[:document][:documentable_type].constantize.find params[:document][:documentable_id]
    @document.documentable = @current_user.project.sections.find params[:document][:documentable_id] # always SECTION 
    if @document.save
      RAILS_DEFAULT_LOGGER.debug "__CHECK__DOCUMENTS_CONTROLLER__CREATE__SAVED__"
      return render :text => {:success => true, :redirect_url => documents_url}.to_json
    else
      RAILS_DEFAULT_LOGGER.debug "__CHECK__DOCUMENTS_CONTROLLER__CREATE__NOT_SAVED__"
      return render :text => {:success => false, :errors => @document.errors}.to_json
    end
  end

  # TODO [11/10/10 10:20 PM] => REMOVE_SHOW
  #  def show
  ##    return render :text => "show :=> DocumentsController"
  #    @document, bln_success = Document.get_document(params[:id])
  #    if(bln_success == 1)
  #      #render partial :)
  #    else
  #      #show error message
  #    end
  #  end

  def list
    @message_main = MarketingTextMessage.find_by_page_and_location("my_files", "main")
    @message_no_doc = MarketingTextMessage.find_by_page_and_location("my_files", "no_document")
    @message_templates = MarketingTextMessage.find_by_page_and_location("my_files", "templates")
  end

  def destroy
    document = Document.find params[:id].to_i
    if document.owner == @current_user
      document.destroy
    end
    if request.xhr?
      render :partial=>'all_sections_panel'
    else
      redirect_to :back
    end
  end

  def download
    document = Document.find params[:id]
    if document.owner != @current_user
      flash[:notice] = "Document not accessible!"
      return redirect_to :back
    else
      send_file document.path
    end
  end

  def upload_document_to_section
    section = Section.find params[:id].to_i
    document = Document.new({:data=>params[:userfile]})
    document.documentable = section
    if document.save
      return render :text => {:success => true, :document_id => document.id.to_s}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => user.errors.as_json}.to_json
    end
  end

  def replace_document
    document = Document.find params[:id].to_i
    document.data = params[:userfile]
    document.name = document.set_default_name
    if document.save
      return render :text => {:success => true}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => user.errors.as_json}.to_json
    end
  end

  def is_file_exist
    section_id = params[:id]
    document = Document.get_with_file_name(params[:file], section_id)
    if document
      return render :text => {:file_exists => true, :document_id => document.id.to_s}.to_json
    else
      return render :text => {:file_exists => false}.to_json
    end
  end

  def update_contents
    document = Document.find params[:id].to_i
    document.name = params[:name]
    document.description = params[:description]
    document.state = State.find params[:state].to_i
    document.tag_list = params[:tags]
    #    if document.update_attributes({:name=>params[:name], :description=>params[:description]})
    if document.save
      return render :text => {:success => true}.to_json
    else
      return render :text => {:success => false, :message => "File Not Saved", :errors => user.errors.as_json}.to_json
    end
  end

  def list_documents
    render :partial=>'all_sections_panel'
  end

  def update_file_content
    if MarketingTextMessage.find(params[:id].to_i).update_attributes(params[:marketing_text_message])
      flash[:notice] = "File Summary updated successfully."
    end
    redirect_to params[:back] || :back
  end

  def show
    @section = Section.find params[:id].to_i
    if request.xhr?
      render :partial => 'section_panel', :locals=>{:section=>@section}
    end
  end
  

  def search
    params[:current_user] = @current_user
    @search_results = Document.search_documents(params, request)
    if request.xhr?
      render :partial => 'search', :locals=>{:documents=>@search_results}
    end
  end
  
  def share_document
    document = Document.find(params[:document_id])
    @document = Hash.new
    @document[:to] = params[:to]
    @document[:from] = @current_user.email
    @document[:sender] = @current_user.name
    @document[:subject] = params[:subject]
    @document[:body] = params[:body]
    @document[:file_name] = document.data_file_name
    unless @document.blank?
      document.deliver_share_document_email(@document)
      return render :text => {:success => true}.to_json
    end
    return render :text => {:success => false}.to_json
  end
  
  private
  def load_content
    @files_content = MarketingTextMessage.get_company_files_contents
  end
  def load_sections
    @sections = @current_user.project.sections.sequence_wise unless @current_user.is_admin?
  end
end
