
if ActiveRecord::Base.connection.tables.include?("site_configs")
  if SiteConfig.exists?(1)
    @latest = SiteConfig.find(:first, :order => "updated_at DESC")
    $SITE_NAME = @latest.site_name
    $ORG_NAME = @latest.org_name
    $SITE_URL = @latest.site_url
    $ORG_URL = @latest.org_url
    $MAIL_SERVER_ADDR = @latest.m_server_addr
    $MAIL_SERVER_PORT = @latest.m_server_port
    $MAIL_SERVER_DOMAIN = @latest.m_server_port
    $RCC_PUB = @latest.rcc_pub
    $RCC_PRIV = @latest.rcc_priv
    $SITE_LOGO_URL = @latest.site_logo_url
    $ORG_LOGO_URL = @latest.org_logo_url
  end
else
  $SITE_NAME = "My Site"
  $ORG_NAME = "{Organization Name}"
  $SITE_URL = "http://127.0.0.1"
  $ORG_URL = "http://example.org"
  $MAIL_SERVER_ADDR = "mail.example.org"
  $MAIL_SERVER_PORT = 25
  $MAIL_SERVER_DOMAIN = "example.org"
  $RCC_PUB = ""
  $RCC_PRIV = ""
  $SITE_LOGO_URL = "images/site-logo.png"
  $ORG_LOGO_URL = "images/org-logo.png"
end

