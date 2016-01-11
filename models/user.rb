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
    # Notice I'm creating the instance variables in the parent class.
    # First I tell the parent API about my Mongo collection which represents this class
    @COLLECTION_NAME = 'users'
    # Now I pass in the fields that will be used as "filters" and the hash containing
    # the actual properties I want to set up. When API is done it will return newly created
    # child instance already populated with the right fields and methods!
    super(@COLLECTION_NAME, fields, hash, self)
  end

  # This class inherits all the parent API methods.

end
