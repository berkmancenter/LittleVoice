
# The file specifies the ScoreType Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies ScoreType and its associations
class Scoretype < ActiveRecord::Base
  has_one :score
end
