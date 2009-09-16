# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include SortHelper
  include ReCaptcha::AppHelper
  filter_parameter_logging :password
  helper :all # include all helpers, all the time
  helper :sort
  
  before_filter :instantiate_controller_and_action_names  
  before_filter :login_required, :only => [:rate]
  after_filter :set_page_description
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '9d8292eb4d39c6b77b125b55193cd131'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def permit(roles)
    
  end
  
  def fix_current_user_problem
    @current_user ||= current_user
  end
  
  def rate(itemid, ratingtype_id)
    
    ## Rating types
    ##  1 up
    ##  2 down
    ##  3 bad (spam/abuse)
    ##  4 nuke
    
    ratingstatus = false
    
    old_rating_value = 0
    rating_value = Ratingtype.find(ratingtype_id).rating_value
    
    if rating_value < 0
      ratingboolean = false
    else
      ratingboolean = true
    end
    
    ### 
    
    ratingactionrecord = Ratingaction.find(:first, :conditions => ["item_id = ? and user_id = ?", itemid, current_user.id])
    
    if ratingactionrecord.nil? || (ratingactionrecord.ratingtype_id != ratingtype_id)
      
      if !ratingactionrecord.nil?
        old_rating_value = Ratingtype.find(ratingactionrecord.ratingtype_id).rating_value * (ratingactionrecord.user_level || 1)
      end
      
      ratingactionrecord = Ratingaction.new() unless !ratingactionrecord.nil?
      
      ratingactionrecord.item_id = itemid
      ratingactionrecord.rating = ratingboolean
      ratingactionrecord.ratingtype_id = ratingtype_id
      ratingactionrecord.user_id = current_user.id
      ratingactionrecord.user_level = current_user.reputation_level
      ratingstatus = ratingactionrecord.save
      
      if ratingstatus
        ratingitemtotalrecord = Ratingitemtotal.find(:first, :conditions => ["item_id = ?", itemid])
        
        ratingitemtotalrecord = Ratingitemtotal.new() unless !ratingitemtotalrecord.nil?
        
        old_total = ratingitemtotalrecord.rating_total
        new_total = (old_total - old_rating_value) + (rating_value * current_user.reputation_level)
        ratingitemtotalrecord.item_id = itemid
        ratingitemtotalrecord.parent_id = Item.find(itemid).parent_id
        ratingitemtotalrecord.rating_total = new_total
        ratingitemtotalrecord.save
      end
    end
    
  end
  
  def allow_moderators_and_admins
    check_for_any_of_roles(['administrator','moderator'])
  end
  
  def allow_admins
    check_for_any_of_roles(['administrator'])
  end
  
  private
  
  def check_for_any_of_roles(roles)
    unless logged_in? && roles.collect{|x| true if @current_user.has_role?(x)}.include?(true)
      if logged_in?
        permission_denied
      else
        store_referer
        access_denied
      end
    end
  end
  
  def set_page_description
    @page_description ||= "BadwareBusters.org is a community of people working together to fight back against viruses, spyware, and other bad software."
  end
  
  def instantiate_controller_and_action_names
    @current_controller = controller_name
    @current_action = action_name
  end  
  
end
