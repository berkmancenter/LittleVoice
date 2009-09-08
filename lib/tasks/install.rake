namespace :lv do
  desc "Install LittleVoice (To be run AFTER editing config/database.yml)"
  task :install => :environment do
    Rake::Task["db:migrate"].invoke
    
    Setting.create(:key => "SITE_NAME", :value => "LittleVoice")
    Setting.create(:key => "ORG_NAME", :value => nil)
    Setting.create(:key => "SITE_URL", :value => "http://127.0.0.1")
    Setting.create(:key => "ORG_URL", :value => nil)
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_ADDR", :value => "localhost")
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_PORT", :value => 25)
    Setting.create(:namespace => "SMTP", :key => "MAIL_SERVER_DOMAIN", :value => "localhost.localdomain")
    Setting.create(:key => "SITE_LOGO_URL", :value => "lv-logo.png")
    Setting.create(:key => "ORG_LOGO_URL", :value => nil)
    Setting.create(:namespace => "recaptcha", :key => "RCC_PUB", :value => "")
    Setting.create(:namespace => "recaptcha", :key => "RCC_PRIV", :value => "")
    
    Role.create :rolename => "administrator", :functionality => "Administrator with all permissions "
    Role.create :rolename => "moderator", :functionality => "A user with selected permissions involved in maintaining the tone of the community"
    Role.create :rolename => "registered user", :functionality => "Has created and activated (via e-mail confirmation) a user account"
    Role.create :rolename => "banned user", :functionality => "Not able to post on the site or to re-register for the site from the email address used to register for the banned username"
    Role.create :rolename => "restricted posting", :functionality => "Member’s posts are held in queue to be moderated"

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
    
    
    
  end
end