namespace :lv do
  desc "Install LittleVoice (To be run AFTER editing config/database.yml)"
  task :install => :environment do

    # Create a new session secret, unique to this installation
    session_initializer = File.new("#{RAILS_ROOT}/config/initializers/session_initializer.rb", "w+")
    if /^1\.9/ =~ RUBY_VERSION
      require 'securerandom'
      session_secret = SecureRandom.base64(128)
    else
      alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
      session_secret = (1..128).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
    end
    session_initializer << "ActionController::Base.session = {:session_key => '_lv_session', :secret => '#{session_secret}'}"
    session_initializer.close
    
    # Set up the database
    Rake::Task["db:migrate"].invoke

    # Create initial settings
    Setting.create(:key => "SITE_NAME", :value => "LittleVoice")
    Setting.create(:key => "ORG_NAME", :value => nil)
    Setting.create(:key => "SITE_URL", :value => "http://localhost:3000")
    Setting.create(:key => "ORG_URL", :value => nil)
    Setting.create(:key => "SITE_LOGO_URL", :value => "lv-logo.png")
    Setting.create(:key => "ORG_LOGO_URL", :value => nil)
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_ADDR", :value => "localhost")
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_PORT", :value => 25)
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_DOMAIN", :value => nil)
    Setting.create(:namespace => "recaptcha", :key => "RCC_PUB", :value => "")
    Setting.create(:namespace => "recaptcha", :key => "RCC_PRIV", :value => "")

    # Create initial role types
    Role.create :rolename => "administrator", :functionality => "Administrator with all permissions "
    Role.create :rolename => "moderator", :functionality => "A user with selected permissions involved in maintaining the tone of the community"
    Role.create :rolename => "registered user", :functionality => "Has created and activated (via e-mail confirmation) a user account"
    Role.create :rolename => "banned user", :functionality => "Not able to post on the site or to re-register for the site from the email address used to register for the banned username"
    Role.create :rolename => "restricted posting", :functionality => "Member’s posts are held in queue to be moderated"

    # Create initial administrator account
    while not (User.find(1) rescue false)
      system('cls') || system('clear')
      puts "Administrator username:\n\n"
      username = STDIN.gets.strip
      system('cls') || system('clear')
      puts "Administrator email:\n\n"
      email = STDIN.gets.strip
      system('cls') || system('clear')
      puts "Administrator password:\n\n"
      password = STDIN.gets.strip
      system('cls') || system('clear')
      begin
        admin = User.create! :login => username, :email => email, :password => password, :password_confirmation => password
        Permission.create :role_id => 1, :user_id => admin.id, :created_at => Time.new, :updated_at => Time.new
        admin.activated_at = Time.now
        admin.save
      rescue 
      end
    end

    # Create initial content
    Content.create(:controller => "main", :action => "index", :name => "welcome", :pseudonym => "Welcome", :location => "/main/index#welcome", :body => "Welcome to LittleVoice!").save_new_version
    Content.create(:controller => "main", :action => "about", :name => "about", :pseudonym => "About", :location => "/main/about#about")
    Content.create(:controller => "main", :action => "howto", :name => "howto", :pseudonym => "How To Use", :location => "/main/howto#howto")
    Content.create(:controller => "main", :action => "contact", :name => "contact", :pseudonym => "Contact Us", :location => "/main/contact#contact")
    Content.create(:controller => "main", :action => "terms", :name => "terms", :pseudonym => "Terms and Conditions", :location => "/main/terms#terms")
    Content.create(:controller => "main", :action => "privacy", :name => "privacy", :pseudonym => "Privacy Policy", :location => "/main/privacy#privacy")
    Content.create(:controller => "main", :action => "copyright", :name => "copyright", :pseudonym => "Copyright", :location => "/main/copyright#copyright")
    
  end
end