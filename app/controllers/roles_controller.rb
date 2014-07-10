class RolesController < ApplicationController
  layout 'application'
  before_filter :check_administrator_role
  # GET /roles
  # GET /roles.xml

  def index
    @user = User.find(params[:user_id])
    @all_roles = Role.find(:all)
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(@role) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    unless @user.has_role?(@role.rolename)
      @user.roles << @role
      @user.enabled = false if @role.rolename == "banned user"
      @user.save!
    end
    redirect_to dashboard_url(:id => @user.login)
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    if @user.has_role?(@role.rolename)
      @user.roles.delete(@role)
      @user.enabled = true if @role.rolename == "banned user"
      @user.save!
    end
    redirect_to dashboard_url(:id => @user.login)
  end
end
