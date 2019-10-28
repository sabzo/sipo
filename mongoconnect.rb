# This class simply returns a MongoDB instane
require 'mongo'
require 'cgi'
class MongoConnect
  # Auto create Reader methods
  attr_reader :username, :password, :host, :port, :database, :uri, :client, :db_name, :client
  def initialize
    @username = ENV['USERNAME']
    @password = CGI.escape( ENV['PASSWORD'] ) if ENV['PASSWORD']
    @host = ENV['HOST']
    @port = ENV['PORT']
    @database = ENV['DATABASE']
    @uri = ENV['MONGODB_URI'] if ENV['MONGODB_URI']
    raise("Missing MongoDB connection details") unless @uri || (@uri or @password or @host or @port or @database) 
    @uri ||= "mongodb://#{username}:#{password}@#{host}:#{port}/#{database}"
    # connect to MongoLab instance
    connect()
  end
  # Connect to MongoLab instance
  private def connect
      @@client ||= Mongo::Client.new(uri)
      @db_name = uri[%r{/([^/\?]+)(\?|$)}, 1]
  end
  # Static function for Singleton Mongo Instance
  def self.client
   @@client
  end

end
