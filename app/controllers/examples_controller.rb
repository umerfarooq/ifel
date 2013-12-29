class ExamplesController < ApplicationController
  before_filter :redirect_nyu_user
  def index
    @examples = Example.all
  end

  def new
    @item_template = ItemTemplate.find params[:item_template_id]
    @example = @item_template.examples.build()
  end

  def create
    @item_template = ItemTemplate.find params[:item_template_id]
    @example = @item_template.examples.build(params[:example])
#    @example.example_category = ExampleCategory.find params[:example][:example_category_id]
#    @example.is_active = true
    @example.state = State.find_by_name('inactivate')
#    @example.item_template.update_attribute(:state, State.find_by_name('inactivate'))
    #    @example.item_template = @item_template
    #    render :xml => params
    #    return render :xml => @example
    if @example.save
      flash[:notice] = "Example successfully added."
      redirect_to @item_template
    else
      render :action => 'new'
    end
  end

  def edit
    @example = Example.find params[:id]
  end

  def update
    @example = Example.find params[:id]
#    @example.state = State.find_by_name('inactivate')
#    @example.item_template.update_attribute(:state, State.find_by_name('inactivate'))
    if @example.update_attributes(params[:example])
      flash[:notice] = "Example successfully updated"
      redirect_to @example.item_template
    else
      render :action => 'edit'
    end
  end

  def show
    @example = Example.find params[:id]
  end

  def publish
    example = Example.find params[:id]
    if example.state == State.find_by_name('activate')
      example.state = State.find_by_name('publish')
      example.save
      flash[:notice] = "Example successfully published"
    else
      flash[:notice] = "Example is not publishable"
    end
    return redirect_to :back
  end

  def activate
    example = Example.find params[:id]
    if example.state == State.find_by_name('inactivate')
      example.state = State.find_by_name('activate')
      example.save
      flash[:notice] = "Example successfully activated"
    else
      flash[:notice] = "Example is not activatable"
    end
    return redirect_to :back
  end

  def inactivate
    example = Example.find params[:id]
    if example.state == State.find_by_name('inactivate')
      flash[:notice] = "Example is not inactivatable"
    else
      example.state = State.find_by_name('inactivate')
      example.save
      flash[:notice] = "Example successfully inactivated"
    end
    return redirect_to :back
  end

  def download
    example = Example.find params[:id]
    send_file example.document.path
  end

end
