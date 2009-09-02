
# The file specifies the SurveyResponse Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies SurveyResponse and its associations
class SurveyResponse < ActiveRecord::Base
  serialize :responses
  #clearing the responses
  def after_initialize
    self.responses ||= {}
  end

end
