# Email settings
ActionMailer::Base.raise_delivery_errors = true

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
:address => "localhost",
#:address  => "oz.law.harvard.edu",
:port => 25,
:domain => "law.harvard.edu"
}
