# The APP API
require 'sinatra/base'
# sinatra-contrib helper modules
require 'sinatra/json'
require 'json'
# authentication
require 'warden'
# import models in the 'models sub directory'
Dir["./models/*.rb"].each { |file| require file }

# Create Routes for API
class App < Sinatra::Base
   enable :sessions
   set :root, File.dirname(__FILE__)
   set :session_secret, "supersecret"

   # Added a authentication logic "strategy" to the Warden Middleware
   Warden::Strategies.add(:password) do
     # If this is a POST request let params be the JSON
     # Determine if request is even valid
     # If the request parameters contain 'username' or 'email' user is probably
     # trying to access an authenticated resource
     def valid?
       if request.post?
         @json = JSON.parse( request.body.read )
         @json['username'] || @json['email']
       elsif request.get?
         # use params
       end

     end
     # Since request is valid, let's authenticate it
     def authenticate!
       req = request.body
       u = User.new().find_one({email: @json['email']})

       if u.id && ( BCrypt::Password.new(u.password) == @json['password'])
          #.set_user(u.id, scope: :user)
          # Store logged in user
          @user = u
          success!(u)
       else
          throw(:warden)
       end
       # Based on results of u `fail` or `approve the request`
     end
   end

   use Warden::Manager do |config|
     # more info at: https://github.com/hassox/warden/wiki/Setup
     config.default_scope = :user
     # If the password strategy fails, the action to take is '/auth/unauthenticated'
     config.scope_defaults :user, :strategies => [:password], :action => '/auth/unauthenticated'
     # If this strategy succeeds save the user ID into the sessions
     config.serialize_into_session{|user| user.email }
     # Using the email stored in sessions, retrieve the User
     config.serialize_from_session{|email| User.new().find_one( {email: email}) }
     config.failure_app = self # This app will handle any failures
   end

   # Whenever a request fails to load, always do the following
   Warden::Manager.before_failure do |env,opts|
     env['REQUEST_METHOD'] = 'POST'
   end

   # Authenticate a user
   post '/auth/login' do
     unless env['warden'].authenticated?(:user)
      env['warden'].authenticate(:password)
     end
     json({ message: "Successfully logged in bruh!"})
   end
   # Response page when user is unauthenticated
   post '/auth/unauthenticated' do
     content_type :json
     json({ message: "Sorry, this request can not be authenticated. Try again." })
   end

    # Log user out!
    get '/auth/logout' do
      env['warden'].raw_session.inspect
      env['warden'].logout
      redirect '/'
   end

   get '/' do
    # HomePage
    p "APP v 1.0"
   end

   # Get a particular article
   get '/user/:id' do |id|
      # First Authenticate before retrieving a user
      env['warden'].authenticate(:password)
      #
     u = User.new().find_one(
       {
         email: @json['email'],
         password: User.encryptPassword(@json['password'])
       })
   end

 end
