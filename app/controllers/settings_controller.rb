class SettingsController < ApplicationController
  before_filter :login_required
  before_filter :fix_current_user_problem
  before_filter :check_administrator_role
  layout "application"

  def index
    @settings = {}
    Setting.all.group_by(&:namespace).each_pair do |namespace, settings|
      ns_hash = {}
      for setting in settings
        ns_hash.merge!({setting.key => setting.value})
      end
      @settings.merge!({namespace => ns_hash})
    end
  end

  def update
    setting_keys = params.keys.select{|key| key.match /^setting\_/}
    for key in setting_keys
      new_value = params[key]
      key = key.gsub(/^setting\_/, '')
      setting = Setting.find(:first, :conditions => {:namespace => key.match(/^[a-zA-Z0-9]+\_/).to_s.gsub(/\_$/, ''), :key => key.gsub(/^[a-zA-Z0-9]+\_/, '')})
      setting.value = new_value == '' ? nil : new_value
      setting.value = eval(setting.value) if setting.value and setting.value.match /^\d+$/
      js_value = (JSON.parse(setting.value) rescue nil)
      if js_value and not js_value.class == String
        js_value.symbolize_keys! if js_value.class == Hash
        setting.value = js_value
      end
       (setting.save && setting.load) if setting.changed?
    end
    redirect_to :action => :index
  end


end
