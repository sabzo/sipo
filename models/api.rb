# This is the master API. All API Models inherit from this class
# Most of the core and complexity resides in this class!
# After DB operations the API updates the state of the class
class Api
   # Every API object will have an ID (after database retrieval)
   # doc represents the doc (properties) of the current object
   attr_reader :id, :doc
   def initialize(collection_name, fields, params={}, child)
     DBSetup()
     # Collection name passed in by the child instance
     @COLLECTION_NAME = collection_name
     # A list arguments to be used for filtering the fields MongoDB will accept
     @fields = fields
     # A hash a user passes is containing the instance variables {'variable' => 'value'}
     @params = params
     # A hash representing all the variables for this particular instance
     @doc = {}
     # When id != nil then this object has been retrieved from the database
     @id = nil
     # The child class passes `self` to super()
     @child = child
     # Take the params hash passed in and dynamically create instance variables
     update_instance_state( params )
   end

  ### Database Operations ####
  # Save Article to to DB using current internal state or arbitrary hash
  def insert(doc = @doc)
    res = @collection.insert_one(doc)
    # TODO don't forget to error check res before returning @child!
    return @child
  end
  # Get an Article from DB
  def find_one (doc = {})
   @collection.find(doc).limit(1).each do |document|
      @doc = document
      @id = document['_id'].to_s
   end
   update_instance_state(@doc)
   return @child
  end
  # Return cursor and .each() the results
  def find_many (doc = {})
    cursor = @collection.find(doc)
  end

  ### Helpers
  protected def DBSetup
    @mongo = MongoConnect.new
    @db = MongoConnect.client
    @collection = @db[ @COLLECTION_NAME ]
  end

  # Update the internal variables
  protected def update_instance_state(doc)
    # Filter hash
    @fields.each do |e|
      if doc.include? e
        doc[e] = Api.encryptPassword(doc[e]) if e == :password
        instance_variable_set( "@#{e.to_s}", doc[e] )
        @doc[e] = doc[e]
      end
    end
  end

  # Static to easily encrypt password
  def self.encryptPassword(plain)
    BCrypt::Password.create(plain)
  end

end
