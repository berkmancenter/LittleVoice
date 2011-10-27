
# The file specifies the Ratingaction Class
#
#
# Author::
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Ratingaction and its associations
class Ratingaction < ActiveRecord::Base
  belongs_to :ratingtype
  belongs_to :user
  belongs_to :item

  before_save Proc.new { |ratingaction| Score.score_vote(ratingaction) }
  before_create :store_user_level

  # user level is made same as the reputation level
  def store_user_level
    self.user_level = self.user.reputation_level
  end

end
