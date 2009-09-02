class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  belongs_to :tagger, :polymorphic => true
  validates_presence_of :context
  
  named_scope :type_pictures, :conditions => "taggable_type = 'Picture'"  
end