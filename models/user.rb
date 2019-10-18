# User Class
require_relative '../mongoconnect'
require 'bcrypt'

class User < Api
  attr_accessor *[
    :firstname,
    :lastname,
    :email,
    :password,
    :city,
    :state,
    :country,
    :created_at,
    :updated_at,
  ]
  # doc is inherited from parent, represents the BSON doc
  attr_reader :articles

  # hash contains symbol keys
  def initialize( hash={} )
    fields = [
      :id,
      :firstname,
      :lastname,
      :email,
      :password, #encrypted_password
      :sign_in_count,
      :role,
      :city,
      :state,
      :country,
      :created_at,
      :updated_at,
      :phone_number,
    ]
    # Notice I'm creating the instance variables in the parent class.
    # First I tell the parent API about my Mongo collection which represents this class
    @COLLECTION_NAME = 'users'
    # Now I pass in the fields that will be used as "filters" and the hash containing
    # the actual properties I want to set up. When API is done it will return newly created
    # child instance already populated with the right fields and methods!
    super(@COLLECTION_NAME, fields, hash, self)
  end

  # Reset a User's password
  # User receives a randomly generated Password
  # At a later point user can change her password
  def reset_password
   client = SendGrid::Client.new(api_key: ENV['SENDGRID_MILCHIMP_MAILER_APIKEY'])
   random_password = Array.new(10).map { (65 + rand(58)).chr }.join
   result = update({}, {password: Api.encryptPassword(random_password)} ).to_a
   # Use either sendgrid, mailchimp, or mail to  send random password
   # https://github.com/mikel/mail
   # IF USING SENDGRID mail hash block would look like this:
   # mail = SendGrid::Mail.new do |m|
   #   m.to = @email
   #   m.from = admin_email
   #   m.subject = 'Admin: Password Reset'
   #   m.text = text
   # end
   #res = client.send(mail) # assume client is a Sendgrid/Mailchimp/Mailer Object
   # reference: https://github.com/sendgrid/sendgrid-ruby
   res = {} # response result when sending mail
   res['code'] == 200 # simulate a successful, ADJUST THIS ACCORDINGLY!
   if res['code'] == 200 and result[0]["ok"] == 1 # if mail and DB update successful
       msg = {message: "Sent temporary password to #{@email}"}
   else
       msg = res.body
   end
   msg # return message
  end
end
