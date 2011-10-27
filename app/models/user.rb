
# The file specifies the User Class
#
#
# Author::
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies User and its associations
require 'digest/sha1'
class User < ActiveRecord::Base
  named_scope :banned, :conditions => {:enabled => 'false'}
  named_scope :active, :conditions => {:enabled => 'true' }

  acts_as_tagger

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 5..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_format_of       :login, :with => /^[\w\s]+$/

  has_one  :reputation, :dependent => :destroy  # destroys the associated ratingactions
  has_many :permissions
  has_many :roles, :through => :permissions

  has_many :items, :dependent => :nullify  # updates the associated records foreign key value to NULL rather than destroying it
  has_many :ratingactions, :dependent => :destroy  # destroys the associated ratingactions
# has_many :itememails, :dependent => :destroy  # destroys the associated itememails
  has_and_belongs_to_many :subscriptions, :join_table => "#{Subscription.connection.instance_eval{@config[:database]}}.subscriptions_users"
  has_many :scores do
    def current
      find :last, :order => "created_at"
    end
  end

  before_save :encrypt_password
  before_create :make_activation_code
  after_create :create_dependencies

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url

  #indexing the fields for ferret
  acts_as_ferret({:fields => [:login, :email], :remote => true})

  class ActivationCodeNotFound < StandardError; end
  class AlreadyActivated < StandardError
    attr_reader :user, :message;
    def initialize(user, message=nil)
      @message, @user = message, user
    end
  end
  # Finds the user with the corresponding activation code, activates their account and returns the user.
  #
  # Raises:
  #  +User::ActivationCodeNotFound+ if there is no user with the corresponding activation code
  #  +User::AlreadyActivated+ if the user with the corresponding activation code has already activated their account
  def self.find_and_activate!(activation_code)
    raise ArgumentError if activation_code.nil?
    user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    raise AlreadyActivated.new(user) if user.active?
    user.send(:activate!)
    user
  end

  def active?
    # the presence of an activation date means they have activated
    !activated_at.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  # Updated 2/20/08
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ?', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end

  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
  end

  def self.find_for_forget(email)
    find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
  end

  def has_role?(rolename)
    self.roles.find_by_rolename(rolename) ? true : false
  end

  def subscribed_to?(subscription)
    self.subscriptions.include?(subscription)
  end

  def unsubscribe_from(subscription)
    self.subscriptions.delete(subscription)
  end

  def subscribe_to(subscription)
    self.subscriptions << subscription
  end

  #returns reputation raw total
  def rawscore
    return reputation.rawscore #if there is no reputation record we WANT an error to be thrown
  end

  #returns reputation log total
  def reputation_level
    score = reputation.rawscore #if there is no reputation record we WANT an error to be thrown
    return ((score || 0) > 0 ? (Math.log(score))**2.3 : 0).floor
  end

  #returns the number of stars a user possesses.  5 stars are required to rescue the princess.
  def stars
    rep = self.rawscore
    return nil if rep.nil?
    return 1 if rep < 5000
    return 2 if rep < 15000
    return 3 if rep < 50000
    return 4 if rep < 250000
    return 5
  end

  #returns last score record
  def last_score
    return self.scores.find(:last, :order => "created_at")
  end

  #returns last login record
  def last_login
    logintypes = Scoretype.find_by_name("login_score")
    login = self.scores.find_by_scoretype_id(logintypes, :order => "created_at DESC")
    time = login.nil? ? Time.new : login.created_at
    return time
  end

  #returns banned user
  def ban
    self.enabled = false
    #add "banned" user role
    self.roles << Role.find_by_rolename("banned user") if self.changed?
    return self if !self.changed? or self.save!
  end

  #returns unbanned user after unbanned
  def unban
    self.enabled = true
    #delete "banned" user role
    self.roles.delete(Role.find_by_rolename("banned user")) if self.changed?
    return self if !self.changed? or self.save!
  end

  def adjust_score(award)
    Score.score_adjustment(self, award)
  end

  def current_rating_type_for_item(item)
    Ratingaction.find(:first, :conditions => ["item_id = ? and user_id = ?", item.id, self.id]).ratingtype_id rescue nil
  end

#  def anonymous?
#    self == User.find_by_login("anonymous")
#  end

  protected



  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    not_openid? && (crypted_password.blank? || !password.blank?)
  end

  def not_openid?
    identity_url.blank? rescue true
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # after filter
  def create_dependencies
    initialscore = 1000
    Score.create(:user_id => self.id, :rawscore => initialscore)
    self.roles << Role.find_by_rolename("registered user")
    #Reputation record is created via before_create filter of Score model
    #logintype = Scoretype.find_by_name('login_score', :order => "version desc")
    #Score.create(:user_id => self.id, :scoretype_id => logintype.id, :total => initialscore)

  end

  private

  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
  end


end
