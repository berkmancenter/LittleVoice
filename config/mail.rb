# Email settings
ActionMailer::Base.raise_delivery_errors = true

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :address => $LV_MAIL_SERVER_ADDR,
  :port => $LV_MAIL_SERVER_PORT,
  :domain => $LV_MAIL_SERVER_DOMAIN
}
