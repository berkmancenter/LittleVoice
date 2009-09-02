class ItemsController < ApplicationController
  # GET /Items
  # GET /Items.xml
  before_filter :check_administrator_role
  def index
    @items = Item.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /Items/1
  # GET /Items/1.xml
  def show
    @item = Item.find(params[:id])
    @item_self_and_ancestors = @item.self_and_ancestors
    @item_root = Item.find(@item.item_root_id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /Items/new
  # GET /Items/new.xml
  def new
    @item = item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /Items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /Items
  # POST /Items.xml
  def create
    @item = item.new(params[:item])

    respond_to do |format|
      if @item.save
        flash[:notice] = 'item was successfully created.'
        format.html { redirect_to(@item) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /Items/1
  # PUT /Items/1.xml
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'item was successfully updated.'
        format.html { redirect_to(@item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /Items/1
  # DELETE /Items/1.xml
  def destroy
    parent = @item.parent
    @item = Item.find(params[:id])
    @item.before_destroy()
    Item.renumber_all
    
    respond_to do |format|
      format.html { redirect_to(parent) }
      format.xml  { head :ok }
    end
  end
  
end
