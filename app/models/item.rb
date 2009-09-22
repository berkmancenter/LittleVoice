
# The file specifies the Item Class and versioning of content
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Items


class Item < ActiveRecord::Base
  named_scope :nuked, :conditions => {:item_active => false }
  named_scope :active, :conditions => {:item_active => true }
  
  named_scope :spammed, :joins => "RIGHT JOIN (SELECT * FROM ratingactions where ratingactions.ratingtype_id = 3) r on r.item_id = items.id", :group => "items.id" do
    
    #Searching on text using Ferret
    #
    #Apparently, ActsAsFerret::SearchResults objects can generate inaccurate attributes 
    #when the ActiveRecord conditions or scope limit the size of results collections beyond
    #the conditions on the ferret index search.  This overriding method within the "spammed" 
    #scope fixes the problem, but only for this scope.
    def find_with_ferret(q, options = {}, find_options = {})
      original = super
      if original.total_hits != original.length
        modified = ActsAsFerret::SearchResults.new(original.collect{|i| i}, original.length)
      end
      return modified || original
    end
  end
  
  # Grabs items that either ARE or ARE NOT conversation roots, conversations are 
  # root Items and responses are non-root Items
  named_scope :conversations, :conditions => "items.id = items.item_root_id"
  named_scope :responses, :conditions => "items.id != items.item_root_id"
  
  #tagging
  acts_as_taggable_on :tags, :categories, :keywords, :special
  Tag.acts_as_ferret({:fields => [:name], :remote => true})
  
  #associations and nestings relating to Items
  belongs_to :user
  has_one :itemtype
  has_many :scores
  has_one :ratingitemtotal, :dependent => :destroy
  has_many :itememails, :dependent => :destroy  # destroys the associated itememails
  
  has_many :ratingactions do
    #criteria for an Item to be spam, currently the logic is if RatingtypeId is >= 3
    def spam
      find :all, :conditions => {:ratingtype_id => 3 } # 3 seems arbitrary - will break if db changes
    end
  end
  
  acts_as_nested_set :scope => :item_root_id
  #ferret specification for the fields to be indexed and 
  acts_as_ferret({:fields => {:item_text => {:boost => 2}, :item_title => {:boost => 5}, :tag_string => {:boost => 10}, :user_name => {:boost => 1}}, :remote => true })
  #for users subscribing to the Item root
  after_create :update_subscriptions
  
  #ranking the conversation (Itemroot)
  def rank
    if is_root?
      conversations = self.class.conversations.find(:all, :select => "id", :include => :ratingitemtotal)
      conversations.select{|i| i.rating_total > self.rating_total}.length + 1
    else
      conversations = self.class.responses.find(:all, :select => "id", :include => :ratingitemtotal, :conditions => {:item_root_id => self.item_root_id})
      conversations.select{|i| i.rating_total > self.rating_total}.length + 1
    end
  end
  
  #resolution in case of tied ranks - 
  def rank_tied?
    unless is_root? # this function doesn't really work for roots, although it wouldn't fail.
      children = self.root.all_children
      ranks = children.collect{|i| i.rank if i.id != self.id } if children
      ranks.include?(self.rank)
    end
  end
  
  #check if the Item is a root (i.e. a conversation)
  def is_root?
    self.id == self.item_root_id
  end
  
  #adding elipsis for longer ItemTitles
  def item_title(elipsis = '', max_length = 55)
    title = super 
    title = self.itemtext.split('\n').first if (title.nil? or title == "")
    if title and title.length <= max_length
      return title
    else
      return (truncate(title, :length => max_length, :omission => elipsis) rescue nil)
    end
  end 
  
  def item_text
    self.itemtext
  end
  #finding the user who nuked the item
  def nuked_by
    if self.item_active == false
      rating = Ratingaction.find(:last, :include => :user, :conditions => {:item_id => self.id, :user_id => self.user_id, :ratingtype_id => 4})
      return rating.user.login if rating
    end
  end
  
  def item_text=(text)
    self.itemtext=(text)
  end
  
  def user_name
    self.user.login rescue nil
  end
  
  def spam_count
    self.ratingactions.spam.length
  end
  
  
  #Nuking an item, ie giving Item an unfavourable rating 
  def nuke(current_user = nil) 
    self.item_active = false
    return if !self.item_active_changed?
    transaction do
      self.rate(current_user, 4) if current_user
      Score.score_nuke(self) if self.save
    end
  end   
  
  #Un-Nuking the item
  def unnuke(current_user = nil) # yeah right.. radioactivity everywhere.
    self.item_active = true
    return if !self.item_active_changed?
    transaction do 
      Score.score_unnuke(self) if self.save
      self.rate(current_user, 1) if current_user
    end
  end
  
  #total for the rating
  def rating_total
    ratingtotal = 0
    ratingitemtotalrecord = Ratingitemtotal.find(:first, :conditions => ["item_id = ?", self.id])
    
    ratingtotal = ratingitemtotalrecord.rating_total unless ratingitemtotalrecord.nil?
    
    return ratingtotal
  end  
  
  ###Deprecated in favor of :rank
  #  def rating_place
  #    ratingplaceset = Ratingitemtotal.find_by_sql(["SELECT ratingitemtotals.item_id, items.item_root_id, ratingitemtotals.rating_total FROM ratingitemtotals LEFT JOIN (items) ON (items.id=ratingitemtotals.item_id) where items.item_root_id = ? order by ratingitemtotals.rating_total DESC", self.item_root_id])
  #    iterator = 0 
  #    matchtest = false
  #    ratingplaceset.each do |ratingrecord|
  #      iterator += 1
  #      
  #      if ratingrecord.item_id == self.id
  #        matchtest = true
  #      end
  #      
  #      break unless ratingrecord.item_id != self.id
  #    end
  #    if matchtest then return iterator else return 0 end
  #  end  
  
  def rating_id(current_user)
    
    ratingtype_id = 0
    
    
    if current_user != :false
      ratingactionrecord = Ratingaction.find(:first, :conditions => ["item_id = ? and user_id = ?", self.id, current_user.id])
      
      if !ratingactionrecord.nil? 
        ratingtype_id = ratingactionrecord.ratingtype_id
      end
    end
    
    return ratingtype_id
  end      
  
  def tag_string
    self.tag_list.join(', ')
  end
  
  #This method rates the Item , RatingTypes are hardcoded in schema
  def rate(current_user, ratingtype_id)
    ## Rating types
    ## * 1 - up
    ## * 2 - down
    ## * 3 - bad (spam/abuse)
    ## * 4 - nuke
    
    #brandon says: I don't know what this does, but I'm leaving it in.
    ratingstatus = false
    old_rating_value = 0
    rating_value = Ratingtype.find(ratingtype_id).rating_value
    if rating_value < 0
      ratingboolean = false
    else
      ratingboolean = true
    end    
    ### 
    
    #keeping the record of the current action
    ratingactionrecord = Ratingaction.find(:first, :conditions => ["item_id = ? and user_id = ?", self.id, current_user.id])    
    if ratingactionrecord.nil? || (ratingactionrecord.ratingtype_id != ratingtype_id) 
      if ratingactionrecord
        old_rating_value = Ratingtype.find(ratingactionrecord.ratingtype_id).rating_value
      else
        ratingactionrecord = Ratingaction.new
      end
      ratingactionrecord.item_id = self.id
      ratingactionrecord.rating = ratingboolean
      ratingactionrecord.ratingtype_id = ratingtype_id
      ratingactionrecord.user_id = current_user.id
      ratingstatus = ratingactionrecord.save
      if ratingstatus
        ratingitemtotalrecord = Ratingitemtotal.find(:first, :conditions => ["item_id = ?", self.id]) 
        ratingitemtotalrecord = Ratingitemtotal.new() unless ratingitemtotalrecord
        old_total = ratingitemtotalrecord.rating_total
        new_total = (old_total - old_rating_value) + rating_value
        ratingitemtotalrecord.item_id = self.id
        ratingitemtotalrecord.rating_total = new_total
        ratingitemtotalrecord.save
      end
    end
  end
  
  
  def update_subscriptions
    Subscription.find_or_create_by_sub_type_and_sub_type_id(:sub_type => "item", :sub_type_id => self.id) if self.id
    if self.tag_list.any?
      self.tag_list.each do |tag|
        Subscription.find_or_create_by_sub_type_and_sub_name(:sub_type => "tag", :sub_name => tag)
      end
    end
  end
  
  def children_count
    return Item.count(:conditions => ["parent_id = ?", self.id])
  end
  
  def place_count
    return Item.count(:conditions => ["item_root_id = ? and lft <= ?", self.item_root_id, self.lft], :order => "lft")
  end
  
  
  protected
  
  
end
