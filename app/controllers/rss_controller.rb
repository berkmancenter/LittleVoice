class RssController < ApplicationController

def index
  @conversations = Item.find :all, :conditions => {:parent_id => nil, :item_active => true}, :order => "created_at DESC", :limit => 20
  render :layout => false, :format => :xml
end

def full
  @conversations = Item.find :all, :conditions => {:item_active => true}, :order => "created_at DESC", :limit => 40
  render :layout => false, :format => :xml
end

def item
  @item = Item.find(params[:id])
  @root_item = @item.id == @item.item_root_id ? @item : Item.find(@item.item_root_id) 
  @conversations = Item.find :all, :conditions => {:item_root_id => @item.item_root_id, :item_active => true}, :order => "created_at DESC", :limit => 20
  render :layout => false, :format => :xml
end

def tag
  @conversations = Item.tagged_with(params[:id], :on => :tags).paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
  render :layout => false, :format => :xml
end

end
