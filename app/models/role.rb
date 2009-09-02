
# The file specifies the Role Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Roles and its associations
class Role < ActiveRecord::Base
   has_many :permissions
   has_many :users, :through => :permissions
end
