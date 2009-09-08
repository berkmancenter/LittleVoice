# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false                                 
config.action_view.debug_rjs                         = true
config.action_controller.session = { :session_key => "_littlevoice_dev_session", :secret => "1dd92b498206f8af69050eafe304dcc1peTkZ8qKHxF0yP3a3tFrFk3Ls5LZz2/0fAkuOfeyCPPHIiwT5u9VY8+vXNzX74PgJ" }

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

$KCODE = 'u' 
RCC_PUB = $RCC_PUB
RCC_PRIV = $RCC_PRIV
 
