class AdminController < ApplicationController
  before_filter :login_required
  before_filter :check_administrator_role, :only => ["invites","send_invitation"]
  before_filter :allow_moderators_and_admins, :except => ["invites","send_invitation"]
  
  layout "application"
  def index
    redirect_to :action => "messages"
#    @lowrateditems = Ratingitemtotal.find(:all, :group => "item_id", :order => 'rating_total DESC', :limit => 10 ).collect{|x| x.item}
#    @spamitems = Ratingaction.find_all_by_ratingtype_id(3, :include => :ratingtype, :group => "item_id", :order => 'ratingactions.created_at DESC').collect{|x| x.item}
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @items }
#    end
  end

  def show
    redirect_to :action => 'index'
  end
  
  def users
    if params[:sort] == "search"
        @users = User.find_with_ferret(params[:search] + '~', {:page => params[:page], :per_page => 25}, {:conditions => params[:conditions]}) 
    elsif (params[:conditions][:enabled] == "false" rescue false)
      if params[:sort] == "reputation"
        @users = User.banned.sort_by{|u| (params[:desc] ? (-1) : 1) * u.rawscore}.paginate :page => params[:page], :per_page => 25
      else
        @users = User.banned.paginate(:order => (params[:sort] ? params[:sort] : "updated_at #{params[:desc] ? 'DESC' : ''}"), :page => params[:page], :per_page => 25)
      end
    elsif params[:sort] == "reputation"
        @scores = Reputation.paginate :order => "rawscore #{ params[:desc] ? 'DESC' : ''}", :per_page => 25, :page => params[:page]
        @users = @scores.collect{|s| s.user }
    elsif params[:sort] == "messages"
      @scores = Item.paginate(:group => :user_id, :order => "count(id) #{params[:desc] ? 'DESC' : ''}", :per_page => 25, :page => params[:page])
      @users = @scores.collect{|s| s.user }
    elsif params[:sort] == "votes"
      @scores = Ratingaction.paginate(:group => :user_id, :order => "count(id) #{params[:desc] ? 'DESC' : ''}", :per_page => 25, :page => params[:page])    
      @users = @scores.collect{|s| s.user }
    else
      @users = User.paginate :page => params[:page], :per_page => 25, :order => "#{params[:sort] ? params[:sort] : 'login'} #{params[:desc] ? 'DESC' : ''}", :conditions => params[:conditions]
    end    
  end

  def messages
    check_for_any_of_roles(['administrator','moderator'])
    if params[:view] == "spam"
      if params[:sort] != "search"
        @messages = Item.paginate :select => "items.*", :from => "items RIGHT JOIN (SELECT * FROM ratingactions where ratingactions.ratingtype_id = 3) r on r.item_id = items.id", :group => "items.id", :order => "#{params[:sort] || 'count(r.id)'} #{params[:desc] ? 'DESC' : ''}", :conditions => params[:conditions], :page => params[:page], :per_page => 25        
      else
        @messages = Item.spammed.find_with_ferret(params[:search] + '~', {:page => params[:page], :per_page => 25}, {:conditions => params[:conditions], :order => "count(r.id)"})
      end
    elsif params[:sort] == "spammed"
      @messages = Item.paginate :select =>  "items.*", :from => "items LEFT JOIN (SELECT * FROM ratingactions where ratingactions.ratingtype_id = 3) r on r.item_id = items.id", :group => "items.id", :order => "count(r.id) #{params[:desc] ? 'DESC' : ''}", :conditions => params[:conditions], :page => params[:page], :per_page => 25
    elsif params[:sort] == "search"
      @messages = Item.find_with_ferret((params[:search] + '~'), {:page => params[:page], :per_page => 25}, {:conditions => params[:conditions]})      
    elsif params[:sort] == "rating"
      @messages = Item.paginate :page => params[:page], :per_page => 25, :include => :ratingitemtotal, :conditions => params[:conditions], :order => "ratingitemtotals.rating_total #{params[:desc] ? 'DESC' : ''}, items.created_at"     
    elsif params[:sort] == "login"
      @messages = Item.paginate :page => params[:page], :per_page => 25, :select => "items.*", :from => "items LEFT JOIN  users ON users.id = items.user_id", :conditions => params[:conditions], :order => "users.login #{params[:desc] ? 'DESC' : ''}"
    else
      @messages = Item.paginate :page => params[:page], :per_page => 25, :conditions => params[:conditions], :order => "#{params[:sort] ? params[:sort] : 'created_at'} #{params[:asc] ? '' : 'DESC'}"
    end
  end

  def invites
    @invites = Invitation.paginate :per_page => 20, :page => params[:page]
  end

  def send_invitation
    if request.post?
      @invite = Invitation.new(params[:invitation])
      @invite.send_code
    else
      @invite = Invitation.find(params[:id])
      @invite.send_code
    end
    flash[:notice] = "Invitation sent to #{@invite.email}"
    redirect_to :action => "invites"
  end

  def nuke
    @item = Item.find(params[:id])
    @item.nuke(current_user)
    redirect_to(request.env["HTTP_REFERER"] || url_for(:action => "messages"))
  end  
  
  def denuke
    @item = Item.find(params[:id])
    @item.unnuke(current_user)
    redirect_to(request.env["HTTP_REFERER"] || url_for(:action => "messages"))
  end  
  
  def ban
    @user = User.find(params[:id])
    @user.ban
    redirect_to(request.env["HTTP_REFERER"] || url_for(:action => "users"))
  end
  
  def unban
    @user = User.find(params[:id])
    @user.unban
    redirect_to(request.env["HTTP_REFERER"] || url_for(:action => "users"))
  end
  
  def vote
    rate(params[:id].to_i, params[:type].to_i)
    render :update do |page|
      page.replace_html "message_#{params[:id]}", :partial => "vote"
    end
  end

protected

  ###
  #Grabs all the responses to a particular survey
  #eg: survey_responses("signup_survey") => [#<SurveyResponse id=1...>, #<SurveyResponse id=2...>]
  def survey_responses(name)
    @responses ||= SurveyResponse.find(:all, :conditions => {:survey_name => name})
  end

  ###
  #Groups survey responses by the response to a particular question
  #eg: response_group("signup_survey", "1") => [["yes", [#<SurveyResponse id=1...>]], ["no", [#<SurveyResponse id=2...>]]]
  def response_group(survey_name, question_key)
    survey_responses(survey_name).group_by{|r| r.responses[question_key]}
  end

  ###
  #Calculates the number of each response for a particular response group
  #eg: stats_for(response_group("signup_survey", "1")) => [["yes", 20], ["no", 4]]
  def stats_for(response_group)
    response_group.sort_by{|i| i[0] || "nil" }.collect{|group| [group[0], group[1].length]}
  end


end
