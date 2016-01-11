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
    :subscription_plan_id
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
      :password,
      :city,
      :state,
      :country,
      :created_at,
      :updated_at,
      :subscription_plan_id
    ]
     # Filter hash for args
     # Nothing fancy just shortcutting having to do variable = value many times!

    @COLLECTION_NAME = 'users'
    super(@COLLECTION_NAME, fields, hash, self)
  end

  def self.encryptPassword(plain)
    BCrypt::Password.create(plain)
  end

  def authenticate(doc={})
    find_one(doc)
  end

end
