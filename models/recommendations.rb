# User Class
require_relative '../mongoconnect'
require 'bcrypt'

class Recommendations < Api
  attr_accessor *[
    :recommendations
  ]
  # doc is inherited from parent, represents the BSON doc
  attr_reader :articles

  # hash contains symbol keys
  def initialize( hash={} )
    fields = [
      :id,
      :recommendations
    ]
    # Notice I'm creating the instance variables in the parent class.
    # First I tell the parent API about my Mongo collection which represents this class
    @COLLECTION_NAME = 'recommendations'
    # Now I pass in the fields that will be used as "filters" and the hash containing
    # the actual properties I want to set up. When API is done it will return newly created
    # child instance already populated with the right fields and methods!
    super(@COLLECTION_NAME, fields, hash, self)
  end

  # calculate recs for each user
  def calculate_recommendations()
    User.new().find_many().each do |u|
      # create sample recommendations!
      recs = []
      for i in 0..5
        recs.push(rand(5))
      end
      # insert recommendations to the users!
      self.insert({recommendations: recs, user_id: u['_id']})
    end
  end
  # generate five users to start
  def generate_five_users()
    for i in 0..5
      u == User.new( {email: "u#{i}" + '@example.com', password: 'plainText'})
    end
  end
  # get recommendations
  def get_unique_recommendations(user_id)
    self.find_one({user_id: user_id}).recommendations
  end

end
