class ContentsController < ApplicationController
  before_filter :login_required
  before_filter :fix_current_user_problem
  before_filter :check_administrator_role
  layout "application"
  # GET /contents
  # GET /contents.xml
  def index
    @contents = Content.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contents }
    end
  end

  # GET /contents/1
  # GET /contents/1.xml
  def show
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content }
    end
  end

  # GET /contents/new
  # GET /contents/new.xml
  def new
    @content = Content.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content }
    end
  end

  # GET /contents/1/edit
  def edit
    @content = Content.find(params[:id])
  end

  def location_preview
    render :text => url_for(:only_path => true, :controller => (params[:location][:controller] == "" ? "main" : params[:location][:controller]), :action => (params[:location][:action] == "" ? nil : params[:location][:action])) + "#{params[:location][:name] == "" ? nil : "#" + params[:location][:name]}"
  end

  def update_preview
    @content = Content.new(params[:content])
    render :text => @content.parse_body
  end

  def show_update
    @content = params[:version] ? Content::Version.find_by_content_id_and_version(params[:id],params[:version]) : Content.find(params[:id])
    render :update do |page|
      page.replace_html "view_content", @content.parse_body
    end
  end

  # POST /contents
  # POST /contents.xml
  def create
    @content = Content.new(params[:content])
    @content.location =  url_for(:only_path => true, :controller => (@content.controller == "" ? "main" : @content.controller), :action => (@content.action == "" ? nil : @content.action)) + "#{@content.name == "" ? nil : "#" + @content.name}"
    respond_to do |format|
      if @content.save
        flash[:notice] = 'Content was successfully created.'
        format.html { redirect_to(@content) }
        format.xml  { render :xml => @content, :status => :created, :location => @content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contents/1
  # PUT /contents/1.xml
  def update
    @content = Content.find(params[:id])
    @content.location =  url_for(:only_path => true, :controller => (params[:content][:controller] == "" ? "main" : params[:content][:controller]), :action => (params[:content][:action] == "" ? nil : params[:content][:action])) + "#{params[:content][:name] == "" ? nil : "#" + params[:content][:name]}"
    respond_to do |format|
      if @content.update_attributes(params[:content])
        flash[:notice] = 'Content was successfully updated.'
        format.html { redirect_to(@content) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
      end
    end
  end

  def publish
    @content = Content.find(params[:id])
    if @content.save_new_version
      flash[:notice] = "Working copy was successfully published."
    else
      flash[:notice] = "There was an error..."
    end
    redirect_to :action => :show
  end

  def revert
    @content = Content.find(params[:id])
    if @content.revert_to_version(params[:version].to_i)
      flash[:notice] = "Content was successfully reverted"
    else
      flash[:notice] = "Reversion failed"
    end
    redirect_to :action => :show
  end

  # DELETE /contents/1
  # DELETE /contents/1.xml
  def destroy
    @content = Content.find(params[:id])
    @content.destroy

    respond_to do |format|
      format.html { redirect_to(contents_url) }
      format.xml  { head :ok }
    end
  end
end
