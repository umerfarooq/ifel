class TemplatificationsController < ApplicationController

  def new
    @item_template = ItemTemplate.find params[:item_template_id]
    @template_documents = TemplateDocument.all
  end

  def create
    @item_template = ItemTemplate.find params[:item_template_id]
#    params[:template_document_ids] ||= []
    params[:item_template] ||= { :template_document_ids => [] }
#    params[:item_template_ids] ||= []
#    params[:item_template_ids] ||= HashWithIndifferentAccess.new
#    params[:item_template][:template_document_ids] ||= []
#return render :json => ["...", params, params[:item_template].class.to_s]
#    @item_template.update_attributes(params[:item_template])
    if @item_template.update_attribute(:template_document_ids, params[:item_template][:template_document_ids])
#      @item_template.update_attribute(:state, State.find_by_name('inactivate'))
      flash[:notice] = "Checklist Item's Template associations successfully updated"
    else
      flash[:notice] = "Checklist Item's Template associations could not be updated"
    end
    return redirect_to item_template_path(@item_template, :type => @item_template.section_template.associated_with)
#    params[:template_document_ids].each do |tdid|
#      #      td = TemplateDocument.find_by_id(tdid)
#      #      if (!td.blank?) && @item_template.template_documents.find_by_id(tdid).blank?
#      #      if (!td.blank?) && Templatification.find_by_item_template_id_and_template_document_id(@item_template.id, td.id).blank?
#      if @item_template.templatifications.find_all_by_template_document_id(tdid).blank?
#        #        tfcn = Templatification.new(:is_active => true)
#        tfcn = Templatification.new
#        tfcn.template_document = TemplateDocument.find_by_id(tdid)
#        tfcn.state = State.find_by_name('activate')
#        #        @item_template.templatifications << tfcn
#        tfcn.item_template = @item_template
#        if tfcn.save
#          flash[:notice] = "Checklist Item's Template association successfully established"
#        else
#          flash[:notice] = "Checklist Item's Template association could not be established"
#        end
#      else
#        flash[:notice] = "Checklist Item's Template association already established"
#      end
#    end
#    redirect_to @item_template
  end

  def destroy
    templatification = Templatification.find params[:id]
    if templatification.destroy
#      templatification.item_template.update_attribute(:state, State.find_by_name('inactivate'))
      flash[:notice] = "Checklist Item's Template association successfully destroyed"
    else
      flash[:notice] = "Checklist Item's Template association could not be destroyed"
    end
    return redirect_to :back
  end

  def publish
    templatification = Templatification.find params[:id]
    if templatification.state.is_activated?
#      templatification.state = State.find_by_name('publish')
#      templatification.save
      if templatification.update_attribute(:state_id, State.find_by_name('publish').id)
        flash[:notice] = "Checklist Item's Template association successfully published"
      else
        flash[:notice] = "Checklist Item's Template association could not be published"
      end
    else
      flash[:notice] = "Checklist Item's Template association is not publishable"
    end
    return redirect_to :back
  end

end
