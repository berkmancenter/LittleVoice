module MainHelper
  
  def conversation_faders(conversations)
    conversations.collect{|c| 
      root = Item.find(c.item_root_id)
      {:id => c.id, 
        :ago => distance_of_time_in_words_to_now(c.created_at) + ' ago',
        :user => escape_javascript(c.user.login), 
        :user_id => c.user.id, 
        :item_text => h(truncate(c.item_text, :length => 250, :omission => '...')).to_xs,
        :root_title => h(root.item_title('...', 35)).to_xs,
        :root_id => root.id
      } }.to_json
  end
  
  def show_item_path(i)
    i.show_path
  end
  
  #Same as escape_javascript except that it doesn't escape newline chars.
  def custom_escape_javascript(javascript)
   (javascript || '').gsub('\\','\0\0').gsub('</','<\/').gsub(/["']/){ |m| "\\#{m}" }.gsub(/\\n/, ' ')
  end
  
  def getitemsummary(userid)
    outputstring = ""
    itemset = Item.find_by_sql(["select * from items where user_id = ? and ISNULL(parent_id)", userid])
    if !itemset.empty?
      itemset.each do |itemrecord|
        linkstring = ""
        linkstring = "<a href='/main/itemview/#{itemrecord.id}'>#{h(itemrecord.itemtext)}</a>"
        outputstring += "<div class='summaryitem'>#{linkstring}</div>\n"
      end
    end
    outputstring
  end
  
  def get_response_summary(itemid)
    outputstring = ""
    itemset = Item.find_by_sql(["select * from items where parent_id = ?", itemid])
    if !itemset.empty?
      itemset.each do |itemrecord|
        linkstring = ""
        linkstring = "#{itemrecord.id}. #{h(itemrecord.itemtext)}"
        outputstring += "<div class='responseitem'>#{linkstring}</div>\n"
        outputstring += "<div id='itemresponse-#{itemrecord.id}' class='replybox'>"
        outputstring +=  link_to_remote('Reply', :update => "itemresponse-#{itemrecord.id}", :url => {:action => "get_reply_box", :item_id => itemrecord.id, :item_root_id => itemid})
        outputstring += "</div>\n"
      end
    end
    outputstring
  end  
  
  def get_responserecords(parent_id, responseset)
    responseset.select {|responseitem| responseitem.parent_id == parent_id}   
  end
  
  def display_responses(parent_id, responseset, marginstart, minscore, maxscore)
    response_array = get_responserecords(parent_id, responseset)
    if response_array.length > 0
      response_array.each do |responserecord|
        unless (responserecord.id).nil?
          score =  responserecord.rating_total
          unless score.nil?
            scorerating = get_score_range(minscore, maxscore, score)
          else
            scorerating = get_score_range(minscore, maxscore, 0)
          end
          scoreclass = "responseitem-state-#{scorerating.to_s}"
          renderhash = {
            :item_id => responserecord.id,
            :minscore => minscore,
            :maxscore => maxscore,
            :leftmargin => marginstart,
            :itemtext => responserecord.itemtext,
            :item_root_id => responserecord.item_root_id,
            :parent_id => responserecord.parent_id,
            :scoreclass => scoreclass,
            :user_login => User.find(responserecord.user_id).login,
            :action => :display_children,
            :childrencount => responserecord.children_count ||= 0,
            :allchildrencount => responserecord.all_children_count ||= 0,
            :level => responserecord.level ||= 0
          }
          outputstring = render(:partial => "itemblock", :locals => renderhash)
        end
      end
    end
    outputstring 
  end
  
  def get_message(message_id)
    message_array = []
    outputstring = ""
    message_array[0] = "<img id='spinner' alt='' src='/images/elements/ajax-loader.gif'/>"
    message_array[1] = "<div class='messageerror'>Something went wrong</div>"
    message_array[2] = "<div class='messagesuccess'>Something went right</div>"
    message_array[3] = "<div class='messageerror'>This item has already been posted.</div>"
    message_array[4] = "<div class='messageerror'>You tried to post an empty item.</div>"
    unless message_id.nil?
      outputstring = message_array[message_id]
    end
    outputstring
  end  
  
  def get_item_error(additemstatus, additemdupe, additemempty, item_id = nil)
    statusmessagestring = ""
    if item_id.nil?
      statusmessagestring = "statusmessage"
    else
      statusmessagestring = "statusmessage-#{item_id.to_s}"
    end    
    page.delay 0.5 do
      if additemstatus
        #page[statusmessagestring].replace_html(get_message(2)) 
      elsif additemstatus == false
        page[statusmessagestring].replace_html(get_message(1))
      elsif additemdupe
        page[statusmessagestring].replace_html(get_message(3))
      elsif additemempty
        page[statusmessagestring].replace_html(get_message(4))
      end
      page.visual_effect(:appear, statusmessagestring,  :duration => 0.25)
    end
  end
  
  def get_rating_display(itemid, rating_initial_id, rating_test_id)  
    off_up = "up_dim.png"
    off_down = "down_dim.png"
    off_bad = "caution_dim.gif"
    on_up = "up.png"
    on_down = "down.png"
    on_bad = "caution.gif"
    off_image = ""
    on_image = ""
    if rating_initial_id == 1
      off_image = off_up
      on_image = on_up 
    elsif rating_initial_id == 2
      off_image = off_down
      on_image = on_down
    elsif rating_initial_id == 3
      off_image = off_bad
      on_image = on_bad
    end
    output = "<img alt='' src='/images/icons/current/#{off_image}' />"
    if rating_initial_id == rating_test_id
      output = "<img alt='' src='/images/icons/current/#{on_image}' />"
    end
    output
  end
  
  def get_rating_box(itemid, minscore, maxscore)
    outputstring = ""
    if current_user
      itemrecord = Item.find(itemid)
      rating_current = itemrecord.rating_id(current_user)
      textclass = "orangetext"
      rate_text = "Rate this message:"
      if itemrecord.root?
        textclass = "bluetext"
        rate_text = "Rate this conversation topic:"
      end
      linkup = link_to_remote(get_rating_display(itemid, 1, rating_current), :url => {:action => :processrating, :item_id => itemid, :ratingtype_id => 1, :minscore => minscore, :maxscore => maxscore})
      linkdown = link_to_remote(get_rating_display(itemid, 2, rating_current), :url => {:action => :processrating, :item_id => itemid, :ratingtype_id => 2, :minscore => minscore, :maxscore => maxscore})
      linkbad = link_to_remote(get_rating_display(itemid, 3, rating_current), :url => {:action => :processrating, :item_id => itemid, :ratingtype_id => 3, :minscore => minscore, :maxscore => maxscore})    
      #linkbad =  submit_to_remote 'link_up', 'Irrelevant', :url => {:action => :processrating, :item_id => itemid, :ratingtype_id => 3, :minscore => minscore, :maxscore => maxscore}
      if (current_user != false) and (itemrecord.user.id != current_user.id)
        outputstring += "<table>\n"
        outputstring += "<tr>  \n"
        outputstring += "  <td class='#{textclass}'>#{rate_text} </td> \n"
        outputstring += "  <td id='up-#{itemid}'>#{linkup}</td> \n"
        outputstring += "  <td id='down-#{itemid}'>#{linkdown}</td> \n"
        outputstring += "  <td id='bad-#{itemid}'>#{linkbad}</td>\n" 
        outputstring += "</tr>\n"
        outputstring += "</table>\n"  
      end
    end
    outputstring
  end
  
  def item_from_place(item_root_id, place_count)
    return Item.find(:first, :conditions => ["item_root_id = ?", item_root_id], :order => "lft", :offset => place_count - 1,:limit => 1)
  end
  
  def display_stars(score_rating, options = {:include_empty => true})
    star_up_image = "star_50.png"
    star_down_image = "star_50_dim.png"
    star_image = ""
    output = ""
    star_array = Array.new(5, false)
    star_array.fill(true, 0..(score_rating.to_i - 1))
    output += "<div class='starblock'>"
    star_array.each do |star_item|
      if star_item 
        star_image = star_up_image 
      elsif options[:include_empty]
        star_image = star_down_image
      else
        next
      end
      output += "<img alt='' src='/images/icons/current/#{star_image}'/>\n"
    end
    output += "</div>"
    return output
  end
  
  def display_badges(user)
    output = ""
    user.roles.each do |role|
      output += "<img alt='' src='/images/badges/badge_#{role.rolename.downcase.gsub(/ /, '_')}.png' />\n"
    end  
    return output
  end

  def item_email_exists?(item_id)
    if item_id == "all_conversations" or item_id == "all_items"
      checked = (Subscription.send(item_id).users.include?(current_user) rescue false)
    elsif item_id == "tag"
      checked = (Subscription.tags.by_name(params[:tag]).users.include?(current_user) rescue false)
    else
      item = item_id.nil? ? Item.new(:user_id => current_user.id) : Item.find(item_id)
      checked = (Subscription.items.by_id(item.item_root_id).users.include?(current_user) rescue false)
    end
  end
  
  def display_emailme(item_id)
    if Subscription.items.by_id(item.item_root_id).users.include?(current_user)
      checked = true
    else
      checked = Item.exists?(:item_root_id => item.item_root_id, :user_id => current_user.id) ? false : true
    end
  end
  
end