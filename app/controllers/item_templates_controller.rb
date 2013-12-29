class ItemTemplatesController < ApplicationController
  uses_tiny_mce :only => [:new,:create,:edit,:update]
  before_filter :require_admin
  before_filter { |c| c.active_tab=:checklist }

  def index
    if params[:section_template_id]
      @section_template = SectionTemplate.find params[:section_template_id]
    else
      if params[:type]
        if params[:type] == 'ifel'
          @item_templates = ItemTemplate.find(:all, :joins => "INNER JOIN section_templates ON item_templates.section_template_id=section_templates.id", :conditions=>['section_templates.associated_with =?','ifel'], :order => "item_number ASC")
        else
          @item_templates = ItemTemplate.find(:all, :joins => "INNER JOIN section_templates ON item_templates.section_template_id=section_templates.id", :conditions=>['section_templates.associated_with =?','wibo'], :order => "item_number ASC")
        end
      else
        @item_templates = ItemTemplate.find(:all, :joins => "INNER JOIN section_templates ON item_templates.section_template_id=section_templates.id", :conditions=>['section_templates.associated_with =?','wibo'], :order => "item_number ASC")
      end      
    end
  end

  def show
    @item_template = ItemTemplate.find params[:id]
  end

  def new
    @item_template = ItemTemplate.new
    @item_template.section_template_id = params[:section_template_id]
    if params[:type]
      if params[:type]=='ifel'
        @section_templates = SectionTemplate.ifel
      else
        @section_templates = SectionTemplate.wibo
      end
    else
      @section_templates = SectionTemplate.wibo
    end      
  end

  def create
    @item_template = ItemTemplate.new(params[:item_template])
    @item_template.section_template_id = params[:item_template][:section_template_id]
    @item_template.state = State.find_by_name('inactivate')
    if @item_template.save
      flash[:notice] = "Item Template successfully added."
      #      if @item_template.section_template
      #        #        @item_template.section_template.update_attribute(:state, State.find_by_name('inactivate'))
      #        return redirect_to @item_template.section_template
      #      end
      return redirect_to item_templates_url(:type => @item_template.section_template.associated_with )
    else
      render :action => 'new'
    end
  end

  def edit
    @item_template = ItemTemplate.find params[:id]
  end

  def update
    @item_template = ItemTemplate.find params[:id]
    #    @item_template.state = State.find_by_name('inactivate')
#    @item_template.section_template_id = params[:item_template][:section_template_id] unless params[:item_template][:section_template_id].blank?
    @item_template.example_description = params[:item_template][:example_description] unless params[:item_template][:example_description].blank?
    if @item_template.update_attributes(params[:item_template])
      #      @item_template.update_attribute(:state, State.find_by_name('inactivate'))
      flash[:notice] = "Item Template successfully updated."
      redirect_to item_template_path(@item_template, :type => @item_template.section_template.associated_with)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @item_template = ItemTemplate.find params[:id]
    if @item_template.destroy
      flash[:success] = "Item Template is deleted."
    else
      flash[:notice] = "Item Template can't be deleted."
    end
    return redirect_to :back
  end

  def toggle_example_type
    item_template = ItemTemplate.find params[:id]
    item_template.update_attribute(:is_example_simple, !(item_template.is_example_simple))
    #    item_template.update_attribute(:state, State.find_by_name('inactivate'))
    if item_template.is_example_simple
      flash[:notice] = "Example Type successfully made SIMPLE"
    else
      flash[:notice] = "Example Type successfully made ATTACHMENTS"
    end
    return redirect_to :back
  end

  def publish
    item_template = ItemTemplate.find params[:id]
    if item_template.state == State.find_by_name('activate')
      item_template.state = State.find_by_name('publish')
      item_template.save
      flash[:notice] = "Item Template successfully published"
    else
      flash[:notice] = "Item Template is not publishable"
    end
    return redirect_to :back
  end

  def activate
    item_template = ItemTemplate.find params[:id]
    if item_template.state == State.find_by_name('inactivate')
      item_template.state = State.find_by_name('activate')
      item_template.save
      flash[:notice] = "Item Template successfully activated"
    else
      flash[:notice] = "Item Template is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    item_template = ItemTemplate.find params[:id]
    if item_template.state == State.find_by_name('inactivate')
      flash[:notice] = "Item Template is not inactivatable"
    else
      item_template.state = State.find_by_name('inactivate')
      item_template.save
      flash[:notice] = "Item Template successfully inactivated"
    end
    return redirect_to :back
  end

  def move_up
    item_template = ItemTemplate.find params[:id]
    if item_template.move_up
      flash[:notice] = "Item Template successfully moved up"
    else
      flash[:notice] = "Item Template could not be moved up"
    end
    return redirect_to :back
  end

  def move_down
    item_template = ItemTemplate.find params[:id]
    if item_template.move_down
      flash[:notice] = "Item Template successfully moved down"
    else
      flash[:notice] = "Item Template could not be moved down"
    end
    return redirect_to :back
  end
  
  def synchronize
    item_template = ItemTemplate.find params[:id]
  
    if item_template.section_template.state.is_published?
      if item_template.state.is_published?  
        if item_template.synchronized
          flash[:notice] = "Item Template successfully synchronized with existing Projects"
        else
          flash[:notice] = "Item Template can't be synchronized with existing Projects"
        end      
      else
        flash[:notice] = "Item Template should be Published before synchronized with existing Projects"
      end
    else
      flash[:notice] = "Section Template, this Item Template is a part of should be Published before synchronized with existing Projects"
    end
    
    return redirect_to :back
  end

end
