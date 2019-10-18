# This is the master API. TREAT THIS AS A C/JAVA ABSTRACT CLASS
# All API Models inherit from this class
# Most of the core and complexity resides in this class!
# After any DB operations the API updates the state of the class.

class Api
   # Every API object will have an ID (after database retrieval)
   # doc represents the doc (properties) of the current object
   # @param collection_name (string)
   # => The Mongo Collection (MySQL table)
   # @param fields (hash) ex: {a: "key 'a' is a symbol"}
   # => The document attributes to be used as filtering
   # @param params (hash)
   # => The fields and values that create the document. Keys are symbols..
   attr_reader :id, :doc, :created_at, :updated_at
   def initialize(collection_name, fields, params={}, child)
     DBSetup()
     # Collection name passed in by the child instance
     @COLLECTION_NAME = collection_name
     # A list arguments to be used for filtering the fields MongoDB will accept
     @fields = fields
     # allow ID to be inserted if user chooses so. Only usesful when needing to delete
     # Don't use for inserting, rather let MongoDB create its own IDs
     @fields << :_id # allows a user to pass in a ID when RETRIEVING or DELETING
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
    doc['created_at'] = Time.now.utc
    doc[:_id] = BSON::ObjectId.new()
    res = @collection.insert_one(doc)

    # TODO don't forget to error check res before returning @child!
    return @child
  end

  # Get an Article from DB
  def find_one (doc = {})
   # doc must be a hash
   # Use the internal doc as a key unless user specifically passes in a doc query
   if !doc.is_a?(Hash) && doc.empty?
      raise "doc is not a Hash"
   end
   # TODO
   doc = @doc if doc.empty?
   # if we're searching by BsonID convert
   if doc.include? :_id
     # doc['_id'] must be actually bsonID or the code breaks!
     doc[:_id] = BSON::ObjectId( doc[:_id] )
   end
   @collection.find(doc).limit(1).each do |document|
      @doc = document
      str_id = document['_id'].to_s
      document['_id'] = str_id
      @id = str_id
   end
   # update the object with the Mongo document just retrieved
   update_instance_state(@doc)
   return @child
  end

  # Return cursor and .each() the results
  def find_many (doc = {})
   if !doc.is_a?(Hash) && doc.empty?
      raise "doc is not a Hash"
   end
    cursor = @collection.find(doc)
  end

  # Update a Document by it's BsonID
  # BSON ID by the time you need to update a document should be in @id
  # Updating a doc means it ALREADY has an @id
  def update(key = {}, doc)
    if !doc.is_a?(Hash) || !key.is_a?(Hash)
      raise "'doc' in update(key, doc) is not a Hash or is empty"
    elsif doc.empty?
      return
    end
    # If the user hasn't specified a key to update a document, use @id
     if key.empty?
      key = {_id: BSON::ObjectId(@id)}
     else # convert string _id into BSON::ID
      key[:_id] = BSON::ObjectId( key[:_id] )
     end
    # update using doc passed in or internal state @doc
    doc = @doc unless doc # If there's no update specifier ($push, $inc, $set) then default to $set doc = {:$set => doc} unless !doc.has_key? :$set
    @collection.update_one(key, doc)
  end

  # Remove a Document based on a key hash or a passed in id hash {}
  def remove_one(key = {})
    if !key.is_a?(Hash)
      raise "doc is not a Hash"
    end
    # if a key doc wasn't provided use internal ID. Assumes @id exists from DB
    key = key.empty?() ? {_id: @doc[:_id]} : key
    if key.include?(:_id)
      key[:_id] = BSON::ObjectId(key[:_id])
      @collection.delete_one(key)
    end
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
        if e == :password
         # If it's already a hashed password don't rehash!
         # doc[e] is a String, determine if it's Bcrypt hash
         begin
          BCrypt::Password.new(doc[e])
         rescue => ex
          doc[e] = Api.encryptPassword(doc[e])
         end
        end
        # Although using symbols to represent keys, instance variables by Ruby rule can't be symbols
        instance_variable_set( "@#{e.to_s}", doc[e] )
        @doc[e] = doc[e]
      end
    end
  end

  # Static function to easily encrypt password
  def self.encryptPassword(plain)
    BCrypt::Password.create(plain)
  end
end
