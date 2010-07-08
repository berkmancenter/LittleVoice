# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  require 'open-uri'
  require 'recaptcha'
  include ReCaptcha::ViewHelper
  
  def load_content(options = {:controller => @current_controller, :action => @current_action})
    @contents = Content.find_all_by_controller_and_action(options[:controller], options[:action]) || []
    if @contents.any?
      @contents.each do |content|
        content_for content.name.downcase.to_sym do
        "<div class=\"content\" id=\"#{content.name}\">" + content.live_version.parse_body + "</div>" rescue nil
        end    
      end
    end
  end
  
  def render_to_string(*args)
    controller.render_to_string(args)
  end
  
  def content_by_name(name, options = {:controller => @current_controller, :action => @current_action})
    content = Content.find_by_controller_and_action_and_name(options[:controller], options[:action], name)
    content ||= Content.find_by_pseudonym(name)
  "<div class=\"content\" id=\"#{content.name}\">" + content.live_version.parse_body + "</div>" rescue nil
  end
  
  def check_role(roles)
    roles.each{|x| return true if current_user.has_role?(x)} rescue false
    return false
  end
  
  def pagination_totals(results)
    total = (results.total_entries rescue results.total_hits)
    if total == 0
    "No results were found"
    else
    "Results #{((results.current_page - 1) * results.per_page  + 1)} - " + 
    "#{(results.current_page * results.per_page) < total ? results.current_page * results.per_page : total}" + 
    " of #{total}"
    end
  end
  
  def resize_embedded_media(text, size = nil)
    text.gsub!(/(\[(youtube|vimeo|flickr))\s+(.*?)(\|(.*?))*\]/) do
      match_data = $~
      media_params = match_data[3].split('|')
      media_params[1] = size if size
     match_data[1] + ' ' + media_params.join('|') + "]"
    end
  end

  
  def tab_for(name, options = {}, html_options = {})
    url = url_for(options)
    modded_params = params
    modded_params.delete(:page)
    modded_params.delete(:per_page)
    active = url_for(modded_params) == url
    html_options.merge!(:class => "tab #{'active_tab' if active}")
    link_to name, url, html_options
  end
  
  def opacity_scale(rating)
    return 1 if rating <= -500
    return 2 if rating <= -100
    return 3 if rating <= 100
    return 4 if rating <= 500
    return 5
  end
  
  def dashboard_url(login)
    url_for :controller => "users", :action => "show", :id => login, :view => "recent"
  end
  
  def display_stars(score_rating)
    
    star_up_image = "star_50.png"
    star_down_image = "star_50_dim.png"
    star_image = ""
    output = ""
    
    star_array = Array.new(5, false)
    
    star_array.fill(true, 0..(score_rating.to_i - 1))
    
    output += "<div class='starblock' align='bottom'>"
    star_array.each do |star_item|
      if star_item then star_image = star_up_image else star_image = star_down_image end
      output += "<img src='/images/icons/current/#{star_image}'/>\n"
    end
    output += "</div>"
    
    return output
    
  end
  
  def display_badges(user)
    
    output = ""
    
    user.roles.each do |role|
      output +=  "<img src='/images/badges/badge_#{role.rolename.downcase.gsub(/ /, '_')}.png' />\n"
    end  
    
    return output
    
  end
  
end
