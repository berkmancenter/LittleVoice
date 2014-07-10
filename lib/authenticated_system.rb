module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != false
    end

    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || false)
    end

    # Store the given user id in the session.
    def current_user=(new_user)
       session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol) || new_user.enabled == false) ? nil : new_user.id
       @current_user = new_user || false
    end

    # Returns true or false if the user is anonymous.
#    def anonymous?
#      current_user == anonymous_user
#    end

    # Returns the anonymous user
#    def anonymous_user
#      User.find_by_login("anonymous")
#    end


    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

     def not_logged_in_required
       !logged_in? || permission_denied
     end

     def check_role(role)
       unless logged_in? && @current_user.has_role?(role)
         if logged_in?
           permission_denied
         else
           store_referer
           access_denied
         end
       end
     end

     def check_administrator_role
       check_role('administrator')
     end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.

     def access_denied
       respond_to do |format|
         format.html do
           store_location
           flash[:error] = "You must be logged in to access this feature."
           redirect_to :controller => '/session', :action => 'new'
         end
         format.xml do
           request_http_basic_authentication 'Web Password'
         end
       end
     end

     def permission_denied
       respond_to do |format|
         format.html do
           #Put your domain name here ex. http://www.example.com
           domain_name = (RAILS_ENV == "production" ? "http://#{$LV_SITE_URL}" : "http://#{$LV_ORG_URL}")
           http_referer = session[:refer_to]
           if http_referer.nil?
             store_referer
             http_referer = ( session[:refer_to] || domain_name )
           end
           flash[:error] = "You don't have permission to complete that action."
           #The [0..20] represents the 21 characters in http://localhost:3000
           #You have to set that to the number of characters in your domain name
           if http_referer[0..(RAILS_ENV == "production" ? 24 : 28)] != domain_name
             session[:refer_to] = nil
             redirect_to RAILS_ROOT
           else
             redirect_to_referer_or_default(RAILS_ROOT)
           end
         end
         format.xml do
           headers["Status"]           = "Unauthorized"
           headers["WWW-Authenticate"] = %(Basic realm="Web Password")
           render :text => "You don't have permission to complete this action.", :status => '401 Unauthorized'
         end
       end
     end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
     def store_location
       session[:return_to] = request.request_uri
     end

     def store_referer
       session[:refer_to] = request.env["HTTP_REFERER"]
     end

     # Redirect to the URI stored by the most recent store_location call or
     # to the passed default.
     def redirect_back_or_default(default)
       redirect_to(session[:return_to] || default)
       session[:return_to] = nil
     end

     def redirect_to_referer_or_default(default)
       redirect_to(session[:refer_to] || default)
       session[:refer_to] = nil
     end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_user = User.authenticate(username, password)
      end
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      user =  User.find_by_remember_token(cookies[:auth_token]) if cookies[:auth_token]
      if user && user.remember_token?
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end

    # Login as anonymous_user
#    def login_as_anonymous
#      self.current_user = anonymous_user
#    end
end
