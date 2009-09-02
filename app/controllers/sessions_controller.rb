# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  require "openid"
  layout 'application'
   before_filter :login_required, :only => :destroy
   before_filter :not_logged_in_required, :only => [:new, :create]
   
   # render new.rhtml
   def new
     session[:return_to] ||= params[:return_to]
   end
  
   def create
    if params[:anonymous]
       login_as_anonymous
       successful_login
    elsif using_open_id?
      open_id_authentication(params[:openid_url])
    else
      password_authentication(params[:login], params[:password])
    end
     if request.xhr?
       render :update do |page|
         page.hide "login_div"
         page.show "submit_question_div"
       end
     end
   end
  
   def destroy
     current_user.forget_me if logged_in?
     cookies.delete :auth_token
     reset_session
     flash[:notice] = "You have been logged out."
   redirect_to '/'    
   end
   
   protected

     def open_id_authentication(openid_url)
      authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(identity_url)
        if @user.new_record?
          if !registration['nickname'].blank? && !registration['email'].blank?
            @user.login = registration['nickname']
            @user.email = registration['email']
            create_open_id_user(@user)
          else
            flash[:notice] = "Your persona must include at a minimum a nickname
                             and valid email address to use OpenID on this site."
            render :action => 'new'
          end
        else
          if @user.activated_at.blank?
            failed_login("Your account is not active, please check your email for the activation code.")
          elsif @user.enabled == false
            failed_login("Your account has been disabled.")
          else
            self.current_user = @user
            successful_login
          end
        end
      else
        failed_login result.message
      end
    end
  end

  def create_open_id_user(user)
    user.save!
    flash[:notice] = "Thanks for signing up! Please check your email to activate your account before logging in."
    redirect_to login_path
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = "Someone has signed up with that nickname or email address. Please create
                             another persona for this site."
    render :action => 'new'
  end
 
   # Updated 2/20/08
   def password_authentication(login, password)
     user = User.authenticate(login, password)
     if user == nil
       failed_login("Your username or password is incorrect.")
     elsif user.activated_at.blank?  
       failed_login("Your account is not active, please check your email for the activation code.")
     elsif user.enabled == false
       failed_login("Your account has been disabled.")
     else
       self.current_user = user
       successful_login
     end
   end
   
   private
   
   def failed_login(message)
     flash.now[:notice] = message
     if request.xhr?
       render :update do |page|
         page.inner_html "errormessage", flash.now[:notice]
       end
     else
      render :action => 'new'
     end
   end
   
   def successful_login
     #Added by LRL to calculate login scores
     Score.score_login(self.current_user)     
     if params[:remember_me] == "1"
       self.current_user.remember_me
       cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
     end
       #flash[:notice] = "Logged in successfully"
       return_to = session[:return_to]  
       if return_to.nil?
         redirect_to :controller => :users, :action => :show, :id => self.current_user.login
       else
         redirect_to CGI::unescape(return_to)
       end
     end

end
