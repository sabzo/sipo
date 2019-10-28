# The APP API
require 'sinatra/base'
# sinatra-contrib helper modules
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'json'
# authentication
require 'warden'
# import models in the 'models sub directory'
if File.exist?("models/api.rb") 
  require_relative "models/api.rb"
  Dir["./models/*.rb"].each { |file| require file }
else
  raise "Missing api.rb in models folder" 
end

# Create Routes for API
class App < Sinatra::Base
   enable :sessions
   set :root, File.dirname(__FILE__)
   set :session_secret, "supersecret"
   set :bind, '0.0.0.0'

   configure do
    enable :cross_origin
   end
    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

   ###
   ## SETUP THE AUTHENTICATION for the API
   ###
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
     ## Since request is valid, let's authenticate it
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
   ## Configure Session and Default Scope
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
   ## Whenever a request fails to load, always do the following
   Warden::Manager.before_failure do |env,opts|
     env['REQUEST_METHOD'] = 'POST'
   end

   ###
   ## Set up CORS: Allows other servers to call this API
   ###
   options "*" do
     response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
     response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
     200
   end
  before do
    # in the future '*' can be www.example.org to only allow users from example.org
    headers 'Access-Control-Allow-Origin' => '*',
         'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST', 'UPDATE'],
         'Access-Control-Allow-Headers' => ['Content-Type', 'Accept', 'X-Requested-With', 'access_token']
    end

    ###
    ##  Helper Functions
    ###
    ## If a request needs to be authenticated call this method
    private def login()
      unless env['warden'].authenticated?(:user)
        env['warden'].authenticate(:password)
      end
    end
    ## Get JSON from request & transform the JSON Object keys into symbols
    private def getJSONFromRequest()
      # variable `request` is known by Sinatra to be the HTTP request
      JSON.parse( request.body.read ).inject({}){|m,(k,v)| m[k.to_sym] = v; m}
    end

   ###
   ## Begin API Routes ##
   ###

   ###
   ## App main entry point
   ###
   get '/' do
    # HomePage
    p "APP v 1.0"
   end
   ###

   ## Auth routes
   ###
   ## Authenticate user and create a session
   post '/auth/login' do
     unless env['warden'].authenticated?(:user)
      env['warden'].authenticate(:password)
     end
     json({ message: "Successfully logged in bruh!"})
   end
   ## Response page when user is unauthenticated
   post '/auth/unauthenticated' do
     content_type :json
     json({ message: "Sorry, this request can not be authenticated. Try again." })
   end
   ## Log user out!
    get '/auth/logout' do
      env['warden'].raw_session.inspect
      env['warden'].logout
      redirect '/'
   end

   ###
   ## USER routes. Create a user, delete a user, modify a user's password etc.,
   ###
   ## Get a particular User
   get '/user' do
     # First Authenticate before retrieving a user
     env['warden'].authenticate(:password)
     @json = getJSONFromRequest()
     u = User.new().find_one({email: @json[:email]})
     #if user was found return the user doc in JSON or return this error message
     if u.id && ( BCrypt::Password.new(u.password) == @json[:password])
       return json(u.doc)
     else
       msg = {message: "The email or password you entered is incorrect"}
       return json(msg)
     end
   end
   ## Create a new user
   post '/user' do
    json = getJSONFromRequest()
    u = User.new(json).insert()
   end
   ## Reset Password
   post '/user/reset' do
     @json = getJSONFromRequest()
     u = User.new().find_one({ email: @json[:email]})
     if u.id
       msg = u.reset_password()
     else
       msg = {message: "Unable to reset password for #{ @json[:email]}"}
     end
     json(msg)
   end
 end
