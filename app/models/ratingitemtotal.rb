
# The file specifies the Ratingitemtotal Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Permissions and its associations
class Ratingitemtotal < ActiveRecord::Base
  belongs_to :item, :dependent => :destroy
  #callback for scoring the Ratingitemtotal
  before_save Proc.new { |r| (r.rating_total ||= 0) and Score.score_item(r) }
  
end
