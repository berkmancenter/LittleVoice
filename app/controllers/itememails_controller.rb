class ItememailsController < ApplicationController

  # GET /itememails/new
  # GET /itememails/new.xml
  def new
    @itememail = Itememail.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @itememail }
    end
  end

  # GET /itememails/1/edit
  def edit
    @itememail = Itememail.find(params[:id])
  end

  # POST /itememails
  # POST /itememails.xml
  def create
    @itememail = Itememail.new(params[:itememail])

    respond_to do |format|
      if @itememail.save
        flash[:notice] = 'Itememail was successfully created.'
        format.html { redirect_to(@itememail) }
        format.xml  { render :xml => @itememail, :status => :created, :location => @itememail }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @itememail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /itememails/1
  # PUT /itememails/1.xml
  def update
    @itememail = Itememail.find(params[:id])

    respond_to do |format|
      if @itememail.update_attributes(params[:itememail])
        flash[:notice] = 'Itememail was successfully updated.'
        format.html { redirect_to(@itememail) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @itememail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /itememails/1
  # DELETE /itememails/1.xml
  def destroy
    @itememail = Itememail.find(params[:id])
    @itememail.destroy

    respond_to do |format|
      format.html { redirect_to(itememails_url) }
      format.xml  { head :ok }
    end
  end
end
