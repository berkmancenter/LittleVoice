
# The file specifies the UserObserver Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies UserObserver a triggger to call
# * method to activation to pending user
# * method to handle forgot password
# * method to handle reset password
class UserObserver < ActiveRecord::Observer
  
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
  end
  
  def after_save(user)  
    UserMailer.deliver_activation(user) if user.pending?
    UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
    UserMailer.deliver_reset_password(user) if user.recently_reset_password?
  end
  
end
