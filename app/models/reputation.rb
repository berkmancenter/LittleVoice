
# The file specifies the Reputation Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Reputation and its associations
class Reputation < ActiveRecord::Base
  belongs_to :user
  #update the score of the user using the provided score
  def self.update_rawscore(score)
    reputation = self.find_or_create_by_user_id(score.user_id)
    reputation.rawscore = score.rawscore
    return reputation.save
  end
end
