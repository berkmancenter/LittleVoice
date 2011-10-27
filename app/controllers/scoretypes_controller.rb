class ScoretypesController < ApplicationController
  # GET /scoretypes
  # GET /scoretypes.xml
  before_filter :check_administrator_role
  def index
    @scoretypes = Scoretype.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scoretypes }
    end
  end

  def show
    redirect_to :action => 'index'
  end

  # GET /scoretypes/new
  # GET /scoretypes/new.xml
  def new
    @scoretype = Scoretype.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scoretype }
    end
  end

  # GET /scoretypes/1/edit
  def edit
    @scoretype = Scoretype.find(params[:id])
  end

  # POST /scoretypes
  # POST /scoretypes.xml
  def create
    @scoretype = Scoretype.new(params[:scoretype])

    respond_to do |format|
      if @scoretype.save
        flash[:notice] = 'Scoretype was successfully created.'
        format.html { redirect_to(@scoretype) }
        format.xml  { render :xml => @scoretype, :status => :created, :location => @scoretype }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scoretype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scoretypes/1
  # PUT /scoretypes/1.xml
  def update
    @scoretype = Scoretype.find(params[:id])

    respond_to do |format|
      if @scoretype.update_attributes(params[:scoretype])
        flash[:notice] = 'Scoretype was successfully updated.'
        format.html { redirect_to(@scoretype) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scoretype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scoretypes/1
  # DELETE /scoretypes/1.xml
  def destroy
    @scoretype = Scoretype.find(params[:id])
    @scoretype.destroy

    respond_to do |format|
      format.html { redirect_to(scoretypes_url) }
      format.xml  { head :ok }
    end
  end
end
