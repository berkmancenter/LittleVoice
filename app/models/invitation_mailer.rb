
# The file specifies the InvitationMailer Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies the Invitation Mail, which wraps the invitation code
# and sends to specified recipients

class InvitationMailer < ActionMailer::Base

   def invitation_email(invitation)
     @recipients = invitation.email
     @from = "contact@#{$SITE_URL}"
     @subject = "#{$SITE_NAME} - Invitation"
     @sent_on = Time.now
     @body[:code] = invitation.code
   end
   
end
