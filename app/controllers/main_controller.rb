class MainController < ApplicationController
  
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::JavaScriptHelper
  
  helper_method :get_score_range, :display_children
  
  before_filter :login_required, :only => ["addresponse","processrating","nuke","unnuke"]
  before_filter :fix_current_user_problem # This really shouldn't be necessary, but our authentication is non-standard :(
  before_filter :check_administrator_role, :only => "unnuke"
  before_filter :allow_moderators_and_admins, :only => ["nuke","make_faq","edit_tags"]
  
  #auto_complete_for :tag, :name
  def auto_complete_for_tag_name(options = {})
    tag = params[:item][:tag_list].split(',').last.strip
    find_options = { 
      :conditions => [ "LOWER(#{:name}) LIKE ?", '%' + tag.downcase + '%' ], 
      :order => "#{:name} ASC",
      :limit => 10 }.merge!(options)
    @items = :tag.to_s.camelize.constantize.find(:all, find_options)
    render :inline => "<%= auto_complete_result @items, '#{:name}' %>"
  end
  
  def index
    @current_user ||= (User.find(session[:user_id]) rescue nil)
    @testvalue = "bobothemonkey"
    @conversations = Item.paginate :page => 1, :per_page => 10, :conditions => {:parent_id => nil, :item_active => true}, :order => "created_at DESC"
  end
  
  def ask
    @page_title = "Start a Discussion"
    @item = Item.new
    if params[:title]
      @title = h(params[:title])
      @tag = h(params[:tag])
      existing = Item.find_by_item_title("Discussion about #{@title}")
      if existing
        redirect_to :controller => "main", :action => "itemview", :id => existing.id
      else
        flash.now[:notice] = "No existing discussion topic was found for this subject, but you can start one here."
        @item.item_title = "Discussion about #{@title}"
        @item.tag_list = @tag
      end
    end
  end
  
  def refresh_questionsummary
    @testvalue = h(params[:testvalue])
    @test2 = "Hello"
  end    
  
  def hide_get_started
    session[:hide_get_started] ||= true
    render :nothing => true, :status => 200
  end
  
  def itemview
    
    @item = Item.find(h(params[:id]).to_i)
    @item_place_id = 0
    @pageitems = 5
    @page_title = @item.item_title.capitalize
    session[:expandhash] ||= Hash.new()
    session[:expandhash][@item.id] ||= Hash.new()
    
    @itemset = @item.children
    @minscore = Ratingitemtotal.minimum(:rating_total, :joins => :item, :conditions => ["items.item_root_id = ? and items.parent_id IS NOT NULL", @item.id])
    @maxscore = Ratingitemtotal.maximum(:rating_total, :joins => :item, :conditions => ["items.item_root_id = ? and items.parent_id IS NOT NULL", @item.id])      
    @minscore ||= 0
    @maxscore ||= 0    
    
    score = @item.rating_total ||= 0
    #scorerating = get_score_range(@minscore, @maxscore, score)
    scorerating = get_score_range(@item)
    
    scoreclass = "responseitem-state-#{scorerating.to_s}"   
    
    @roothash = {
      :item_id => @item.id,
      :item_root_id => @item.item_root_id,
      :parent_id => @item.parent_id,
      :itemtext => @item.item_text,
      :scorerating => scorerating,
      :scoreclass => scoreclass,
      :user_login => @item.user.login,
      :minscore => @minscore,
      :maxscore => @maxscore,
      :childrencount => @item.children_count ||= 0,
      :allchildrencount => @item.all_children_count ||= 0,
      :level => 0      
    }
  end
  
  def additem
    @additemstatus = nil
    @additemdupe = false
    @additemempty = true
    itemtext = params[:item][:itemtext].strip
    
    if itemtext.downcase == "needs moar ponies"
      render :update do |page|
        page.redirect_to "http://images.google.com/images?q=ponies&oe=utf-8&rls=org.mozilla:en-US:official&client=firefox-a&um=1&ie=UTF-8&sa=N&tab=wi"
      end    
      itemtext = ""
    end
    
    if !itemtext.empty?
      
      @additemempty = false  
      
      @additemdupe = Item.exists?(:itemtext => itemtext, :parent_id => nil)
      
      if !@additemdupe
        login_as_anonymous if params[:anonymous]
        #if using_open_id?
        #  authenticate_with_open_id(params[:openid_url], :required => [:nickname, :email]) do |result, identity_url, registration|
        #    unless result.successful?
        #      flash[:notice] = result.message
        #      return
        #    end
        #  end
        #end
        unless @current_user 
          flash[:item] = params[:item]
          flash[:email_me] = params[:itememailcheckbox]
          @current_user = User.authenticate(params[:login], params[:password])
          if @current_user and @current_user.enabled
            session[:user_id] = @current_user.id
          else
            session[:user_id] = false
            @current_user = false
          end
        end
        unless @current_user
          if params[:accept].to_i == 1 
            user = User.new(params[:user])
            @current_user = user if (validate_recap(params, user.errors) && user.save rescue false)
            flash[:notice] = "Thanks for signing up! Please check your email to activate your account before logging in." if current_user
            flash[:signed_up] = true
          end
        end
        if @current_user and @current_user.enabled
          itemrecord = Item.create()
          itemrecord.tag_list = params[:item][:tag_list]
          itemrecord.user_id = @current_user.id
          itemrecord.itemtype_id =  1
          itemrecord.item_root_id =  itemrecord.id
          itemrecord.item_active = true
          itemrecord.itemtext =  itemtext
          itemrecord.item_title = h(params[:item][:item_title].strip)
          @additemstatus = itemrecord.save
          itemrecord.update_subscriptions
          @item = itemrecord          
          
          #Add or delete this user from following this conversation
          if params[:itememailcheckbox]
            Subscription.items.by_id(@item.id).users << @current_user
          end
          
          mailed = []
          
          #send emails to other subscribers to all_items
          Subscription.all_items.users.reject{|u| mailed.include? u }.each do |user|
            UserMailer.deliver_item_email_me(user, @item) if user.enabled
            mailed << user
          end
          
          #send emails to everyone who subscribes to all conversations
          Subscription.all_conversations.users.reject{|u| mailed.include? u }.each do |user|
            UserMailer.deliver_item_email_me(user, @item) if user.enabled
            mailed << user
          end
          
          #Send emails to everyone who is following this item's tags.
          @item.tag_list.each do |tag|
            Subscription.tags.by_name(tag).users.reject{|u| mailed.include? u }.each do |user|
              UserMailer.deliver_tag_email_me(user, @item, tag) if user.enabled
              mailed << user
            end
          end          
        else
          render :update do |page|
            page.replace_html "errormessage", "There was a problem with your login or registration"
            page.hide "spinner"
          end
        end
      end
    end
    
  end 
  
  def addresponse
    @additemstatus = nil
    @additemdupe = false
    @additemempty = true
    
    itemtext = params[:item][:item_text].strip
    @itemid = h(params[:item_id].strip).to_i
    @item_root_id = h(params[:item_root_id].strip).to_i
    
    if !itemtext.empty?
      
      @additemempty = false  
      
      @additemdupe = Item.exists?(:itemtext => itemtext, :item_root_id => @item_root_id)
      
      if !@additemdupe
        itemrecord = Item.new()
        
        itemrecord.user_id = current_user.id
        itemrecord.itemtype_id =  1
        itemrecord.item_root_id = @item_root_id
        #itemrecord.parent_id = @itemid
        itemrecord.item_active = true
        itemrecord.itemtext =  itemtext
        itemrecord.tag_list = params[:item][:tag_list]
        @additemstatus = itemrecord.save
        
        @newitem = itemrecord
        
        itemrecord.move_to_child_of @itemid
        
        #Email all users following this conversation
        item_email_all(@newitem)
        mailed = []
        
        #Send emails to everyone who subscribes to all messages
        Subscription.all_items.users.reject{|u| mailed.include? u}.each do |user|
          UserMailer.deliver_item_email_me(user, @newitem) if user.enabled
          mailed << user
        end
        
        #Send emails to everyone who is following this item's tags.
        @newitem.tag_list.each do |tag|
          Subscription.tags.by_name(tag).users.reject{|u| mailed.include? u }.each do |user|
            UserMailer.deliver_tag_email_me(user,@newitem, tag) if user.enabled
            mailed << user
          end
        end
        
        
        
      end
    end
    
    #@itemset = Item.find_by_sql(["select * from items where item_root_id = ?", @item_root_id])
    @itemset = Item.find(@item_root_id).children
  end
  
  #Make this item a FAQ, or not (Gives a :special tag of "faq")
  def make_faq
    item = Item.find(params[:id])
    stylehash = params[:stylehash]
    
    item.special_list.include?("faq") ? item.special_list.delete("faq") : item.special_list << "faq"
    item.save
    render :update do |page|
      page.replace_html "make_faq", :partial => "make_faq", :locals => {:item => item, :stylehash => stylehash}
    end
  end
  
  def edit_tags
    @item = Item.find(params[:id])
    if (params[:item][:tag_list] rescue false)
      @item.tag_list = params[:item][:tag_list]
      @item.save
    end
  end
  
  #Email me
  def item_email_me
    item_id = params[:item_id]
    user_id = params[:user_id]
    stylehash = params[:stylehash]
    
    if item_id == "tag"
      subscription = Subscription.tags.by_name(params[:tag])
    else
      subscription = ((item_id == "all_conversations" or item_id == "all_items") ? Subscription.send(item_id) : Subscription.items.by_id(item_id))
    end
    user = User.find(user_id)
    if subscription.users.include? user
      subscription.users.delete(user)
      checked = false
    else 
      subscription.users << user
      checked = true 
    end
    render :update do |page|
      partial = ((["all_conversations","all_items","tag"].include? item_id) ? "email_me_all" : "email_me")
      page.replace_html "emailme", :partial => partial, :locals => {:item_id => item_id, :user_id => current_user.id, :tag => params[:tag], :stylehash => stylehash}
    end
  end
  
  def item_email_all(item_id)
    #Get the item
    item = Item.find(item_id)
    #Get all users following this conversation
    subscription = Subscription.items.by_id(item.item_root_id)
    #Email users
    subscription.users.each do |user| 
      UserMailer.deliver_item_email_me(user,item) if user.enabled #unless disabled or banned.
    end
  end
  
  def display_children(item_id = nil, minscore = nil, maxscore = nil)
    
    if !item_id.nil?
      methodcallstate = true
    end
    
    outputstring = ""
    item_id ||= h(params[:item_id]).to_i
    minscore ||= h(params[:minscore]).to_i
    maxscore ||= h(params[:maxscore]).to_i
    
    itemrecord = Item.find(item_id) 
    item_root_id = itemrecord.item_root_id
    childrencount = itemrecord.children_count
    allchildrencount = itemrecord.all_children_count
    
    if !itemrecord.nil?
      
      #childhash = Hash.new()
      childhash = {
        :action => "display_children",
        :item_id => item_id,
        :item_root_id => item_root_id,
        :minscore => minscore,
        :maxscore => maxscore,
        :level => itemrecord.level.to_i * 10,
        :childrencount => childrencount,
        :allchildrencount => allchildrencount
      }
      
      collapsehash = childhash
      collapsehash[:action] = "collapse_children"
      
      #session[:expandhash][itemrecord.item_root_id][item_id] = true  
      
      childset = itemrecord.children  
      
      #outputstring += child_collapse_link
      #outputstring += link_to_remote('-', :update => "childblock-#{item_id}", :url => collapsehash)
      
      childset.each do |childrecord|
        
        score =  childrecord.rating_total ||= 0
        #scorerating = get_score_range(minscore, maxscore, score)
        scorerating = get_score_range(itemrecord)
        
        scoreclass = "responseitem-state-#{scorerating.to_s}"      
        
        childhash = {
          :item_id => childrecord.id,
          :item_root_id => childrecord.item_root_id,
          :parent_id => childrecord.parent_id,
          :itemtext => childrecord.item_text,
          :scorerating => scorerating,
          :scoreclass => scoreclass,
          :user_login => childrecord.user.login,
          :minscore => minscore,
          :maxscore => maxscore,
          :childrencount => childrecord.children_count ||= 0,
          :allchildrencount => childrecord.all_children_count ||= 0,
          :level => childrecord.level.to_i * 10     
        }
        
        outputstring += render_to_string(:partial => "itemblock", :locals => childhash)
        outputstring += render_to_string(:partial => "childrenblock", :locals => childhash)
      end
      
      if request.xhr?
        return outputstring
      else
        return (render :text => outputstring)
      end
      
    end
    
  end
  
  def collapse_children
    
    renderhash  = {
      :item_id => h(params[:item_id]).to_i,
      :item_root_id => h(params[:item_root_id]).to_i,
      :minscore => h(params[:minscore]).to_i,
      :maxscore => h(params[:maxscore]).to_i,
      :level => h(params[:level]).to_i * 10,
      :childrencount => h(params[:childrencount]).to_i,
      :allchildrencount => h(params[:allchildrencount]).to_i
    }
    
    render(:partial => "collapseblock", :locals => renderhash)
  end
  
  def processrating
    
    item_id = h(params[:item_id]).to_i
    ratingtype_id = h(params[:ratingtype_id]).to_i
    minscore = h(params[:minscore]).to_i
    maxscore = h(params[:maxscore]).to_i
    responserecord = Item.find(item_id)
    rate(item_id, ratingtype_id) unless responserecord.user_id == @current_user.id
    #ratingtotal = get_rating_total(item_id)
    
    #if ratingtype_id == 1
    
    #end
    
    render :update do |page|
      
      #linkup = link_to_remote(get_rating_display(item_id, 1, ratingtype_id), :url => {:action => :processrating, :item_id => item_id, :ratingtype_id => 1})
      #linkdown = link_to_remote(get_rating_display(item_id, 2, ratingtype_id), :url => {:action => :processrating, :item_id => item_id, :ratingtype_id => 2})
      #linkbad = link_to_remote(get_rating_display(item_id, 3, ratingtype_id), :url => {:action => :processrating, :item_id => item_id, :ratingtype_id => 3})    
      
      
      
      score =  responserecord.rating_total
      
      if !score.nil?
        scorerating = get_score_range(responserecord)
      else
        scorerating = get_score_range(responserecord)
      end
      
      scoreclass = "responseitem-state-#{scorerating.to_s}"
      
      renderhash = {
        :item_id => item_id,
        :minscore => minscore,
        :maxscore => maxscore,
        :itemtext => responserecord.itemtext,
        :item_root_id => responserecord.item_root_id,
        :parent_id => responserecord.parent_id,
        :scoreclass => scoreclass,
        :user_login => User.find(responserecord.user_id).login,
        :childrencount => responserecord.children_count ||= 0,
        :allchildrencount => responserecord.all_children_count ||= 0,
        :level => responserecord.level.to_i * 10        
      }      
      
      #page.replace_html("itemblock-#{item_id}", render(:partial => "itemblock", :locals => renderhash))      
      page.replace("itemblock-#{item_id}", render(:partial => "itemblock", :locals => renderhash))      
      
    end
    
  end
  
  def edit_item
    @item = Item.find(params[:id])
    if (current_user.id == @item.user.id && @item.created_at > 60.minutes.ago) || @current_user.has_role?('administrator')
      @item.itemtext = params[:item][:itemtext]
      @item.save if @item.changed?
      @item.itemtext = @item.itemtext.to_xs
      @item.item_title = @item.item_title.to_xs
      render :update do |page|
        page.redirect_to "/main/itemview/#{@item.item_root_id}?t=#{rand(10000)}#itemblock-#{@item.id}"
      end
    else
      @item = nil
      flash[:notice] = "This item can not be edited."  
      render :update do |page|
        page.replace_html "itemresponse-#{@item.id}", ''
      end 
    end
  end
  
  def get_edit_box
    @item = Item.find(params[:id])
    if (@item.created_at > 30.minutes.ago && @item.user.id == current_user.id) || @current_user.has_role?('administrator')
      render :update do |page|
        page.replace_html "itemresponse-#{@item.id}", :partial => "edit_item"
      end
    else
      @item = nil
      flash[:notice] = "This item can no longer be edited."
    end
  end
  
  def get_reply_box
    @item = Item.new(:tag_list => Item.find(params[:item_id]).tag_list)
    item_id = params[:item_id]
    item_root_id = params[:item_root_id]
    item_user_id = params[:item_user_id]
    if !item_id.nil? and !item_root_id.nil?
      render(:partial => "item_reply", :locals => {:item_id => item_id, :item_root_id => item_root_id, :item_user_id => item_user_id})
    end
  end
  
  def get_score_range(item)
    
    outputclass = 0
    rating_total = 0
    
    if !item.ratingitemtotal.nil?
      rating_total = item.ratingitemtotal.rating_total
    else
      rating_total = 0
    end
    
    maxrating = Ratingitemtotal.maximum(:rating_total, :conditions => ["parent_id = ?", item.parent_id])
    
    if (rating_total == maxrating) && (rating_total > 0)
      outputclass = 5
    else
      if rating_total > 0
        outputclass = 5
      elsif rating_total == 0
        outputclass = 4
      elsif rating_total.between?(-500, 0) 
        outputclass = 3
      elsif rating_total <= -500
        outputclass = 2
      end
    end
    
    return outputclass
  end
  
  # def rate(item_id, ratingtype_id)  Moved to ApplicationController  
  
  #def get_score_range(min, max, score)
  
  #  scorevalue = 0
  
  #  rangearray = (min.to_i..max.to_i).to_a  
  #  rangelength = rangearray.length
  #  multiplier =  5/rangelength.to_f
  #  scorevalue = (rangearray.index(score) + 1) unless rangearray.index(score).nil?
  #  outputclass = 0
  
  
  
  
  #  if score != 0 
  #    if (0..1).include?(scorevalue * multiplier) then outputclass = 1
  #    elsif (1..2).include?(scorevalue * multiplier) then outputclass = 2
  #    elsif (2..3).include?(scorevalue * multiplier) then outputclass = 3
  #    elsif (3..4).include?(scorevalue * multiplier) then outputclass = 4
  #    elsif (4..5).include?(scorevalue * multiplier) then outputclass = 5
  #    end
  #  else
  #     outputclass = 4
  #  end
  
  
  #  outputclass
  
  #end
  
  
  
  def conversations
    tags
    @page_title = "Conversations"
    params[:view] = "all_conversations" if params[:view] == "recent" or params[:view].nil?
    #    @top_answers = Item.paginate :page => params[:page], :per_page => 20, :include => :ratingitemtotal, :conditions => "parent_id IS NOT NULL and item_active = true", :order => "ratingitemtotals.rating_total DESC, items.created_at DESC" 
    case params[:view]
      when "popular"
      @conversation_title = "Top rated by the community"
      @conversations = Item.paginate :page => params[:page], :per_page => 20, :include => :ratingitemtotal, :conditions => {:parent_id => nil, :item_active => true}, :order => "ratingitemtotals.rating_total DESC, items.created_at DESC"
      when "all_conversations"
      @conversation_title = "Most recent topics"
      @conversations = Item.paginate :page => params[:page], :per_page => 20, :conditions => {:parent_id => nil, :item_active => true}, :order => "created_at DESC"
      when "all_items"
      @conversation_title = "All posts"
      @conversations = Item.paginate :page => params[:page], :per_page => 20, :conditions => {:item_active => true}, :order => "created_at DESC"
      when "active"
      @conversations = Item.paginate :page => params[:page], :per_page => 20, :select => "*, count(id)", :group => "item_root_id", :order => "count(id) DESC, created_at DESC", :conditions => {:item_active => true}
      when "no_replies"
      @conversation_title = "Topics awaiting a response"
      @conversations = Item.paginate_by_sql("select *, count(id) from items where item_active = true group by item_root_id having count(id) = 1 order by created_at DESC", :page => params[:page], :per_page => 20)
      when "tag"
      @conversation_title = "Messages tagged with: #{h(params[:tag])}"
      case params[:kind]
        when "topics"
        @conversations = Item.conversations.tagged_with(params[:tag], :on => :tags).paginate :page => params[:page], :per_page => 20, :order => "created_at DESC"
        when "responses"
        @conversations = Item.responses.tagged_with(params[:tag], :on => :tags).paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
      else
        @conversations = Item.tagged_with(params[:tag], :on => :tags).paginate :page => params[:page], :per_page => 20, :conditions => {:item_active => true}, :order => "created_at DESC"
      end
      when "faq"
      @conversation_title = "Selected by the moderators"
      @conversations = Item.tagged_with("faq", :on => :special).paginate :page => params[:page], :per_page => 20, :conditions => {:item_active => true}, :order => "created_at DESC"
    end
    if @conversations.empty?
      redirect_to :controller => "main", :action => "ask", :title => params[:tag], :tag =>params[:tag]
    end
  end
  
  def tags
    @all_tags = Item.tag_counts.sort_by(&:count).reverse
    @max_count = (@all_tags.first.count.to_f rescue 0)
    @tags = @all_tags.paginate :per_page => 20, :page => params[:page]
  end
  
  def survey
    redirect_to "/"
  end
  
  def search
    if (params[:search][:q] rescue false)
      @page_title = "Search Results"
      @items = Item.find_with_ferret(params[:search][:q] + '~')
      @conversations = (@items.group_by(&:item_root_id).collect{|group| group[1].first}.paginate(:per_page => 20, :page => params[:page]) rescue @items.paginate(:per_page => 20, :page => params[:page]))
      @conversation_title = "Searched for: #{h(params[:search][:q])}"
      tags
      render :action => "conversations"
    end
  end
  
  def nuke
    item = Item.find(params[:id])
    item.nuke
    
    stylehash = params[:stylehash]
    
    render :update do |page|
      page.replace_html "admin_#{item.id}", :partial => "inline_admin", :locals => {:item => item, :stylehash => stylehash}
    end
  end
  
  def unnuke
    item = Item.find(params[:id])
    item.unnuke
    
    stylehash = params[:stylehash]
    
    render :update do |page|
      page.replace_html "admin_#{item.id}", :partial => "inline_admin", :locals => {:item => item, :stylehash => stylehash}
    end
  end
  
end
