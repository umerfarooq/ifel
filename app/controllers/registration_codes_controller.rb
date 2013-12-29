class RegistrationCodesController < ApplicationController
  before_filter :require_admin
  before_filter { |c| c.active_tab=:content_tab }
  
  # GET /registration_codes
  # GET /registration_codes.xml
  def index
    @registration_codes = RegistrationCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registration_codes }
    end
  end

  # GET /registration_codes/1
  # GET /registration_codes/1.xml
  def show
    @registration_code = RegistrationCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registration_code }
    end
  end

  # GET /registration_codes/new
  # GET /registration_codes/new.xml
  def new
    @registration_code = RegistrationCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registration_code }
    end
  end

  # GET /registration_codes/1/edit
  def edit
    @registration_code = RegistrationCode.find(params[:id])
  end

  # POST /registration_codes
  # POST /registration_codes.xml
  def create
    @registration_code = RegistrationCode.new(params[:registration_code])

    respond_to do |format|
      if @registration_code.save
        format.html { redirect_to(registration_codes_path, :notice => 'RegistrationCode was successfully created.') }
        format.xml  { render :xml => @registration_code, :status => :created, :location => @registration_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @registration_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /registration_codes/1
  # PUT /registration_codes/1.xml
  def update
    @registration_code = RegistrationCode.find(params[:id])

    respond_to do |format|
      if @registration_code.update_attributes(params[:registration_code])
        format.html { redirect_to(registration_codes_path, :notice => 'RegistrationCode was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @registration_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_codes/1
  # DELETE /registration_codes/1.xml
  def destroy
    @registration_code = RegistrationCode.find(params[:id])
    @registration_code.destroy

    respond_to do |format|
      format.html { redirect_to(registration_codes_path) }
      format.xml  { head :ok }
    end
  end
  
  def activate
    @registration_code = RegistrationCode.find(params[:id])
    if @registration_code.activate
      flash[:notice] = "Registration Code successfully activated"
    else
      flash[:notice] = "Registration Code is not activatable"
    end
    return redirect_to registration_codes_path
  end

  def inactivate
    @registration_code = RegistrationCode.find(params[:id])
    if @registration_code.inactivate
      flash[:notice] = "Registration Code is successfully inactivated "
    else
      flash[:notice] = "Registration Code is not inactivatable"
    end
    return redirect_to registration_codes_path
  end
  
end
