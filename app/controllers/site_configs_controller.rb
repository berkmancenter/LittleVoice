class SiteConfigsController < ApplicationController
  before_filter :login_required
  before_filter :check_administrator_role, :only => ["invites","send_invitation"]
  before_filter :allow_moderators_and_admins, :except => ["invites","send_invitation"]

  # The Site Config Panel
  # Management of Configurations
  
  def show
    @site_configs = SiteConfig.find(:all , :order =>"updated_at DESC")
  end
 
  def index
    @site_configs = SiteConfig.find(:all , :order =>"updated_at DESC")
  end
  
  def new
    @site_config = SiteConfig.new
  end 
  
  def create
    @site_config = SiteConfig.new(params[:site_config])
    @site_config.save(params[:site_config])
    site_config_loader(@site_config)
    redirect_to :action => :index
  end

  def edit
    @site_config = SiteConfig.find(params[:id])
  end
  
  def update
    @site_config = SiteConfig.find(params[:id])
    @site_config.update_attributes(params[:site_config])
    site_config_loader(@site_config)
    redirect_to :action => :index
  end
  
  #def destroy_site_config
  #  @iteration = Iteration.find(params[:id])
  #  @iteration.destroy
  #end
 
  def site_config_loader (config)
    if SiteConfig.exists?(config.id)
      @latest = config
    else
      @latest = SiteConfig.find(:first, :order => "updated_at DESC")
    end
    
    $SITE_NAME = @latest.site_name
    $ORG_NAME = @latest.org_name
    $SITE_URL = @latest.site_url
    $ORG_URL = @latest.org_url
    $MAIL_SERVER_ADDR = @latest.m_server_addr
    $MAIL_SERVER_PORT = @latest.m_server_port
    $MAIL_SERVER_DOMAIN = @latest.m_server_domain
    $RCC_PUB = @latest.rcc_pub
    $RCC_PRIV = @latest.rcc_priv
    $SITE_LOGO_URL = @latest.site_logo_url
    $ORG_LOGO_URL = @latest.org_logo_url

  end

end
