# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_controller.session = { :session_key => "_littlevoice_session", :secret => "1dd92b498206f8af69050eafe304dcc1peTkZ8qKHxF0yP3a3tFrFk3Ls5LZz2/0fAkuOfeyCPPHIiwT5u9VY8+vXNzX74PgJ" }
# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

  # Include your app's configuration here:
  ActionMailer::Base.smtp_settings = {
    :address  => $MAIL_SERVER_ADDR,
    :port  => $MAIL_SERVER_PORT,
    :domain => $MAIL_SERVER_DOMAIN
  } 

$KCODE = 'u' 
RCC_PUB = $RCC_PUB
RCC_PRIV = $RCC_PRIV
#RCC_PUB = "6LcIAgQAAAAAAD0l4Eko0IhkLROZSyk8oDxzXKEh" 
#RCC_PRIV = "6LcIAgQAAAAAAIP4GQlxURC8B4dcpmI461hEw4UM" 
