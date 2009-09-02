
# The file specifies the UserMai Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies UserMail and the various template mails that would be sent
# to a user
class UserMailer < ActionMailer::Base
   
   def signup_notification(user)
     setup_email(user)
     @subject    += 'Please activate your new account'  
     @body[:url]  = "#{$SITE_URL}/activate/#{user.activation_code}"  
   end
   
   def activation(user)
     setup_email(user)
     @subject    += 'Your account has been activated!'
     @body[:url]  ="http://#{$SITE_URL}"
   end
   
   def forgot_password(user)
     setup_email(user)
     @subject    += 'You have requested to change your password'
     @body[:url]  = "http://#{$SITE_URL}/reset_password/#{user.password_reset_code}"
   end
  
   def reset_password(user)
     setup_email(user)
     @subject    += 'Your password has been reset.'
   end
  #email the user about an Item   
  def item_email_me(user, item)
    setup_email(user)
    @from = "no-reply@#{$SITE_URL}"
    @subject += (item.id == item.item_root_id ? item.item_title('...') : Item.find(item.item_root_id).item_title('...'))
    @subject = "Re: #{@subject}" if item.id != item.item_root_id
    @body[:user] = item.user
    @body[:item] = item
    @body[:url]  = "http://#{$SITE_URL}/main/itemview/#{item.item_root_id}#itemblock-#{item.id}"
    @body[:root_url] = "http://#{$SITE_URL}/main/itemview/#{item.item_root_id}"
  end  
  # email the user about tag 
  def tag_email_me(user, item, tag_name)
    setup_email(user)
    @from = "no-reply@#{$SITE_URL}"
    @subject += "Tag: #{tag_name} - #{item.item_title('...')}"
    @body[:url]  = "http://#{$SITE_URL}/main/itemview/#{item.item_root_id}#itemblock-#{item.id}"
    @body[:tag_url] = "http://#{$SITE_URL}/conversations?view=tag&tag=#{tag_name}"
    @body[:item] = item
    @body[:tag_name] = tag_name
    @body[:user] = item.user
  end
   
   protected
     def setup_email(user)
       @recipients  = "#{user.email}"
       @content_type = "text/html"
       @from        = "contact@#{$SITE_URL}"
       @subject     = "[#{$SITE_NAME}] "
       @sent_on     = Time.now
       @body[:user] = user
     end
 end

