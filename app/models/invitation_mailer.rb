###
# DEPRECATED
class InvitationMailer < ActionMailer::Base

   def invitation_email(invitation)
     @recipients = invitation.email
     @from = "contact@#{$SITE_URL}"
     @subject = "#{$SITE_NAME} - Invitation"
     @sent_on = Time.now
     @body[:code] = invitation.code
   end
   
end
