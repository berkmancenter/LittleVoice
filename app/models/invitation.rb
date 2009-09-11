###
# DEPRECATED
class Invitation < ActiveRecord::Base
belongs_to :user

#array of Alphanumerics to generate code from
ALPHANUMS = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9"].freeze

# generate the invitation code using random string
def generate_code
  self.code ||= generate_random_string
  self.save!
end

# generate the random string from the arrafy of alphanumerics
def generate_random_string(size = 15)
  (1..size).map do 
   (ALPHANUMS.map{|n|n.to_s})[rand(ALPHANUMS.size)]
  end.join
end

#use the InvitationMailer to send the code
def send_code
  generate_code unless self.code
  InvitationMailer.deliver_invitation_email(self)
end

end
