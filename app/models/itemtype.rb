
# The file specifies the Itemtype Class
#
#
# Author::
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Itemtype
class Itemtype < ActiveRecord::Base
  has_many :items
  validates_uniqueness_of :item_type
end
