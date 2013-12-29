class TemplateDocumentsController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :require_admin, :except => [:index, :download]
  before_filter :require_user,  :only   => [:index, :download]
  before_filter { |c| c.active_tab = :template_tab }

  def new
    @template_document = TemplateDocument.new
  end

  def create
    @template_document = TemplateDocument.new(params[:template_document])

    if @template_document.save
      flash[:notice] = "Template successfully added."
      redirect_to template_documents_url
    else
      render :action => 'new'
    end
  end

  def index
    if params[:c]
      case params[:c]
      when 'title'
        @template_documents = TemplateDocument.title_wise(params[:d])
      when 'updated_at'
        @template_documents = TemplateDocument.update_wise(params[:d])  
      end      
    else
      @template_documents = TemplateDocument.title_wise('asc')
    end    
  end

  def edit
    @template_document = TemplateDocument.find params[:id]
  end

  def update
    @template_document = TemplateDocument.find params[:id]

    if @template_document.update_attributes(params[:template_document])
      flash[:notice] = "Template successfully updated."
      redirect_to template_documents_url
    else
      render :action => 'edit'
    end
  end

  def publish
    template_document = TemplateDocument.find params[:id]
    if template_document.state.is_activated?
      template_document.state = State.find_by_name('publish')
      template_document.save
      flash[:notice] = "Template Document successfully published"
    else
      flash[:notice] = "Template Document is not publishable"
    end
    redirect_to template_documents_url
  end

  def activate
    template_document = TemplateDocument.find params[:id]
    if template_document.state.is_inactivated?
      template_document.state = State.find_by_name('activate')
      template_document.save
      flash[:notice] = "Template Document successfully activated"
    else
      flash[:notice] = "Template Document is not activatable"
    end
    redirect_to template_documents_url
  end

  def inactivate
    template_document = TemplateDocument.find params[:id]
    if template_document.state.is_inactivated?
      flash[:notice] = "Template Document is not inactivatable"
    else
      template_document.state = State.find_by_name('inactivate')
      template_document.save
      flash[:notice] = "Template Document successfully inactivated"
    end
    redirect_to template_documents_url
  end

  def featurify
    template_document = TemplateDocument.find params[:id]
    if template_document.state.is_published?
      template_document.state = State.find_by_name('featurify')
      template_document.save
      flash[:notice] = "Template Document successfully featurified"
    else
      flash[:notice] = "Template Document is not featurifiable"
    end
    redirect_to template_documents_url
  end

  def download
    #http://thewebfellas.com/blog/2009/8/29/protecting-your-paperclip-downloads # TODO [11/10/10 11:13 PM] => PROTECT
    template_document = TemplateDocument.find params[:id]
    send_file template_document.document.path
  end

end
