
# The file specifies the Reputation Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Reputation and its associations
class Reputation < ActiveRecord::Base
  belongs_to :user
  before_create Proc.new{|rep| rep.rawscore = 0 if rep.rawscore.nil? }

  after_save :ban_user_if_necessary
  #update the score of the user using the provided score
  def self.update_rawscore(score)
    reputation = self.find_or_create_by_user_id(score.user_id)
    reputation.rawscore = score.rawscore
    return reputation.save
  end
  
  def ban_user_if_necessary
    if self.rawscore and self.rawscore < -25000
      self.user.ban
      UserMailer.deliver_auto_banned(self.user)
    end
  end
end
