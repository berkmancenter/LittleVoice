# Stores namespaced global settings in the db, all of which are loaded at initialization.
#
# General usage:
#
# Setting.create(:namespace => "flickr", :key => "API_KEY", :value => "9aj9fhsli3u48").load => "9aj9fhsli3u48"
# $FLICKR_API_KEY => "9aj9fhsli3u48"
#
# NAMESPACES are designed to separate LittleVoice application settings from plugin or customization settings.
# the default namespace if one is not provided is "LV", so keys that are set without a namespace will result in
# global variables like $LV_{key_name}.
#
# VALUES permitted are any ruby objects that can be serialized to YAML.  That's almost any ruby object.
# Strings and numbers are probably appropriate in most cases.
#
# LOADING individual settings should not be necessary in most cases because the settings_initializer loads all
# existing settings by default; however, if you change a setting or wish to reload it, simply call load().

class Setting < ActiveRecord::Base
  serialize :value
  before_save :normalize
  after_save :restart_if_necessary
  @@restart_namespaces = %w( SMTP RECAPTCHA ).map(&:upcase)
  validates_format_of :namespace, :with => /^[A-Za-z0-9]+$/

  def load
    eval("$#{self.name} = self.value || nil")
  end

  def name
    "#{self.namespace}_#{self.key}".upcase
  end

  def key=(string)
    write_attribute(:key, string)
    normalize
  end

  def normalize
    write_attribute(:key, self.key.gsub(/\s/, '_').upcase)
    write_attribute(:namespace, self.namespace.upcase)
  end

  def restart_if_necessary
    if @@restart_namespaces.include?(self.namespace.upcase) and $LV_ENABLE_PASSENGER_RESTART
      FileUtils.touch "#{RAILS_ROOT}/tmp/restart.txt" rescue flash[:notice] = "Manual restart is required"
    end
  end

  def self.restart_namespaces
    @@restart_namespaces
  end

  def self.restart_namespaces=(ns_array)
    @@restart_namespaces = (@@restart_namespaces + ns_array).flatten.uniq.map(&:upcase)
    return @@restart_namespaces
  end

end
