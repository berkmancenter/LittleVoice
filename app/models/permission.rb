
# The file specifies the Permissions Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Permissions and its associations
class Permission < ActiveRecord::Base
   belongs_to :user
   belongs_to :role
end
