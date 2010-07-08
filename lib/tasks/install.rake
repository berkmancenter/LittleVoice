namespace :lv do
  desc "Install LittleVoice (To be run AFTER editing config/database.yml)"
  task :install => :environment do

    # Create a new session secret, unique to this installation
    session_initializer = File.new("#{RAILS_ROOT}/config/initializers/session_initializer.rb", "w+")
    if /^1\.9/ =~ RUBY_VERSION
      require 'securerandom'
      session_secret = SecureRandom.base64(128)
    else
      session_secret = ActiveSupport::SecureRandom.base64(128)
    end
    session_initializer << "ActionController::Base.session = {:session_key => '_lv_session', :secret => '#{session_secret}'}"
    session_initializer.close

    # Set up the database
    Rake::Task["db:schema:load"].invoke

    # Create initial settings
    Setting.create(:key => "SITE_NAME", :value => "LittleVoice")
    Setting.create(:key => "ORG_NAME", :value => nil)
    Setting.create(:key => "SITE_URL", :value => "http://localhost:3000")
    Setting.create(:key => "ORG_URL", :value => nil)
    Setting.create(:key => "SITE_LOGO_URL", :value => "lv-logo.png")
    Setting.create(:key => "ORG_LOGO_URL", :value => nil)
    Setting.create(:namespace => "GOOGLE", :key => "ANALYTICS_ID", :value => nil)
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_ADDR", :value => "localhost")
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_PORT", :value => 25)
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_DOMAIN", :value => nil)
    Setting.create(:namespace => "RECAPTCHA", :key => "RCC_PUB", :value => "")
    Setting.create(:namespace => "RECAPTCHA", :key => "RCC_PRIV", :value => "")
    Setting.create(:key => "FACEBOOK_PAGE_URL", :value => nil)
    Setting.create(:key => "TWITTER_URL", :value => nil)
    
    # Create initial role types
    Role.create :rolename => "administrator", :functionality => "Administrator with all permissions "
    Role.create :rolename => "moderator", :functionality => "A user with selected permissions involved in maintaining the tone of the community"
    Role.create :rolename => "registered user", :functionality => "Has created and activated (via e-mail confirmation) a user account"
    Role.create :rolename => "banned user", :functionality => "Not able to post on the site or to re-register for the site from the email address used to register for the banned username"
    Role.create :rolename => "restricted posting", :functionality => "Member’s posts are held in queue to be moderated"

    # Create initial score types
    Scoretype.create :name => "pos_score", :award => 1000, :description => "every message with a net positive community rating!", :version => 1
    Scoretype.create :name => "login_score", :award => 100, :description => "every week (or 7-day period) in which a user logs in", :version => 1
    Scoretype.create :name => "vote_score", :award => 200, :description => "every week (or 7-day period) in which a user votes on a message", :version => 1
    Scoretype.create :name => "neg_score", :award => -2000, :description => "every message with a net negative community rating", :version => 1
    Scoretype.create :name => "nuke_score", :award => -500, :description => "every message that was actively nuked by a moderator (passive nukage is a metaphysical impossibility)", :version => 1
    Scoretype.create :name => "unnuke_score", :award => 500, :description => "every message that was actively de-nukified by a moderator", :version => 1
    Scoretype.create :name => "adjust_score", :award => 0, :description => "adjustments made by the administrator", :version => 1
    
    # Create initial rating types
    Ratingtype.create(:rating_type => "up", :rating_value => 1)
    Ratingtype.create(:rating_type => "down", :rating_value => -1)
    Ratingtype.create(:rating_type => "bad (spam/abuse)", :rating_value => -1)
    Ratingtype.create(:rating_type => "nuke", :rating_value => -1)

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

    # Create site subscriptions
    Subscription.create(:sub_type => "item", :sub_name => "all_conversations")
    Subscription.create(:sub_type => "item", :sub_name => "all")

    # Create initial content
    Content.create(:controller => "main", :action => "index", :name => "welcome", :pseudonym => "Welcome", :location => "/main/index#welcome", :textile => true, :body => "Welcome to LittleVoice!").save_new_version
    Content.create(:controller => "main", :action => "about", :name => "about", :pseudonym => "About", :textile => true, :location => "/main/about#about")
    Content.create(:controller => "main", :action => "howto", :name => "howto", :pseudonym => "How To Use", :textile => true, :location => "/main/howto#howto")
    Content.create(:controller => "main", :action => "contact", :name => "contact", :pseudonym => "Contact Us", :textile => true, :location => "/main/contact#contact")
    Content.create(:controller => "main", :action => "terms", :name => "terms", :pseudonym => "Terms and Conditions", :textile => true, :location => "/main/terms#terms")
    Content.create(:controller => "main", :action => "privacy", :name => "privacy", :pseudonym => "Privacy Policy", :textile => true, :location => "/main/privacy#privacy")
    Content.create(:controller => "main", :action => "copyright", :name => "copyright", :pseudonym => "Copyright", :textile => true, :location => "/main/copyright#copyright")

    puts "\n-- Installation Complete \n-- Try running the application with 'ruby script/server'\n-- Visit /settings to modify site settings, or /content to edit or publish site content.\n"
  end
end