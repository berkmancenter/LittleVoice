class SettingsController < ApplicationController
  before_filter :login_required
  before_filter :check_administrator_role
  layout "application"
  
  def index
    @settings = {}
    for setting in Setting.find(:all, :conditions => {:namespace => "LV"})
      @settings.merge!({setting.name => setting.value})
    end
  end

end
