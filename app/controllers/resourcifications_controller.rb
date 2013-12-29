class ResourcificationsController < ApplicationController

  def new
    @item_template = ItemTemplate.find params[:item_template_id]
    @resources = Resource.all
  end

  def create
    @item_template = ItemTemplate.find params[:item_template_id]
    params[:item_template] ||= { :resource_ids => [] }
    if @item_template.update_attribute(:resource_ids, params[:item_template][:resource_ids])
#      @item_template.update_attribute(:state, State.find_by_name('inactivate'))
      flash[:notice] = "Checklist Item's Resource associations successfully updated"
    else
      flash[:notice] = "Checklist Item's Resource associations could not be updated"
    end
#    params[:resource_ids].each do |rid|
#      r = Resource.find_by_id(rid)
#      #      if (!td.blank?) && @item_template.resources.find_by_id(tid).blank?
#      if (!r.blank?) && Resourcification.find_by_item_template_id_and_resource_id(@item_template.id, r.id).blank?
#        rfcn = Resourcification.new(:is_active => true)
#        rfcn.resource = r
#        rfcn.state_id = (State.find_by_title("create")).id
#        @item_template.resourcifications << rfcn
#      end
#    end
    return redirect_to item_template_path(@item_template, :type => @item_template.section_template.associated_with)
  end

  def destroy
    #    @item_template = ItemTemplate.find params[:item_template_id]
    resourcification = Resourcification.find params[:id]
    #    return render :text => [params[:item_template_id], params[:item_template_id].class, @resourcification.item_template_id.to_s, @resourcification.item_template_id.to_s.class].to_s
#    if(@resourcification.item_template_id.to_s == params[:item_template_id])
#      @resourcification.destroy
#    end
#    return redirect_to item_template_url(:id => params[:item_template_id])
    if resourcification.destroy
#      resourcification.item_template.update_attribute(:state, State.find_by_name('inactivate'))
      flash[:notice] = "Checklist Item's Resource association successfully destroyed"
    else
      flash[:notice] = "Checklist Item's Resource association could not be destroyed"
    end
    return redirect_to :back
  end

  def publish
    resourcification = Resourcification.find params[:id]
    if resourcification.state.is_activated?
      if resourcification.update_attribute(:state_id, State.find_by_name('publish').id)
        flash[:notice] = "Checklist Item's Resource association successfully published"
      else
        flash[:notice] = "Checklist Item's Resource association could not be published"
      end
    else
      flash[:notice] = "Checklist Item's Template association is not publishable"
    end
    return redirect_to :back
#    @resourcification = Resourcification.find params[:id]
#    if(@resourcification.item_template_id.to_s == params[:item_template_id])
#      @resourcification.state = State.find_by_name('published')
#      @resourcification.save
#    end
#    return redirect_to item_template_url(:id => params[:item_template_id])
  end

end
