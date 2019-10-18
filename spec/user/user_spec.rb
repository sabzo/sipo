require 'rspec'
require '../models/api'
require '../models/user'

RSpec.describe User do
  it "creates a new user" do
     u1 = User.new( {email: 'email@example.com', password: 'plainText'}).insert()
 
  end

  it "retrieves a user" do
  
  end

  it "updates a user's information" do
  end

  it "deletes a user" do
  end

end

