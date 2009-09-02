
# The file specifies the Ratingtype Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Ratingtype and its associations
class Ratingtype < ActiveRecord::Base
  has_one :ratingactions
end
