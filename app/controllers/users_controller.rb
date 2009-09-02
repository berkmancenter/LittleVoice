class UsersController < ApplicationController
  
   layout 'application'
   before_filter :not_logged_in_required, :only => [:create] 
   before_filter :login_required, :only => [:edit, :update, :ban_toggle, :toggle_subscription]
   before_filter :check_administrator_role, :only => [:index, :destroy, :enable, :adjust_score]

   def index
     @users = User.find(:all)
   end
   
   def show     
     @page_title = "Dashboard"
     params[:view] ||= "recent"
     @tabview = params[:view]
     
     render :action => "new" if current_user == false && params[:id].nil?
     @user = current_user
     @all_roles = Role.find(:all)
     #only administrators can view profiles of other users
     #return if !current_user.has_role?('administrator')
     params[:id].nil? ? @user : @user = User.find_by_login(params[:id])

     #set view parameters
     return if @user.nil? || current_user.anonymous?
     @admin = true if current_user.has_role?("administrator")
     @account = true if  @admin || (current_user.id == @user.id)

     if params[:view] == "" or params[:view].nil?
       @tabview = "recent"
     end
      @items = @user.items.paginate(:page => params[:page], :per_page => 15, :order => "created_at DESC") if @tabview == "recent"
   end
     
   # render new.rhtml
   def new
     @page_title = "Sign up"
     fix_current_user_problem
     @user = User.new
   end
  
   def create
     cookies.delete :auth_token
#     invite = Invitation.find_by_code(params[:invitation_code])
#     if (invite.used != true rescue false)
       begin
         @user = User.new(params[:user])
         if params[:accept].to_i == 1 
           @user.save!
#           invite.used = true
#           invite.user_id = @user.id
#           invite.save!
           #Uncomment to have the user logged in after creating an account - Not Recommended
           #self.current_user = @user
            flash[:notice] = "Thanks for signing up! Please check your email to activate your account before logging in."
            flash[:signed_up] = true
           redirect_to :controller => "main", :action => "survey"
         else
          flash[:notice] = "You must accept the Terms & Conditions to register"
          render :action => "new"
         end
       rescue ActiveRecord::RecordInvalid
         flash[:notice] = "There was a problem creating your account."
         render :action => 'new'
       end
#     else
#       flash[:error] = "An valid invitation code is required to register at this time."
#       render :action => 'new'
#     end
   end
   
   def request_invitation
     Invitation.create(:email => params[:email])
     flash[:notice] = "Thank you for your interest in BadwareBusters.org"
     render :action => "new"
   end
   
   def edit
     @user = current_user
   end
   
   def update
     @user = User.find(current_user)
     if @user.update_attributes(params[:user])
       flash[:notice] = "User updated"
       redirect_to :action => 'show', :id => current_user
     else
       render :action => 'edit'
     end
   end
   
   def destroy
     @user = User.find(params[:id])
     if @user.update_attribute(:enabled, false)
       flash[:notice] = "User disabled"
     else
       flash[:error] = "There was a problem disabling this user."
     end
     redirect_to :action => 'index'
   end
   
   def toggle_subscription
     @user = User.find(params[:user])
     if @current_user.id == @user.id or @current_user.has_role?("administrator")
       @subscription = Subscription.find(params[:id])
       @user.subscriptions.include?(@subscription) ? @subscription.users.delete(@user) : @subscription.users << @user
     end
     render :update do |page|
       page.replace_html "subscriptions", :partial => "subscriptions", :locals => {:user => @user}
     end
   end
   
   def ban_toggle
     if @current_user.has_role?("administrator") or @current_user.has_role?("moderator")
       @user = User.find(params[:id])
       #add or delete "banned" user role
       banned_role = Role.find_by_rolename("banned user")
       if @user.enabled and !@user.roles.include?(banned_role)
         @user.roles << banned_role 
       elsif !@user.enabled
         @user.roles.delete(banned_role)
       end
       @user.enabled = !@user.enabled
       @user.save
     end
     redirect_to :action => "show", :id => @user.login
   end
   
   def adjust_score
     @user = User.find(params[:id])
     @user.adjust_score(params[:adjustment].to_i)
     redirect_to :action => "show", :id => @user.login, :view => "recent"
   end
   
#   def enable
#     @user = User.find(params[:id])
#     if @user.update_attribute(:enabled, true)
#       @user.roles.delete(Role.find_by_rolename("banned user"))
#       flash[:notice] = "User enabled"
#     else
#       flash[:error] = "There was a problem enabling this user."
#     end
#       redirect_to :action => 'index'
#   end
end
