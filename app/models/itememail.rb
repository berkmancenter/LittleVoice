
# The file specifies the Itememail
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Itememail
class Itememail < ActiveRecord::Base
  belongs_to :item
  belongs_to :user
end
