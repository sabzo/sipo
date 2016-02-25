# Sipo  -  Sinatra MongoDB Starter Code

## API
Sipo uses Sinatra framework, warden for Authentication
[Warden](http://github.com/hassox/warden) and MongoDB for storage.

This is simply minimalistic starter code to be used for a simple Ruby MongoDB web-app.
## Usage (in irb shell for example)

```ruby
 # BEFORE ANYTHING set up Environment Varaibles for MongoDB connection!! -- mongoconnect.rb
 # Can simply use a Rack Server to run or in irb for example you can do the following
 # include the API starting point
 require_relative 'app'

 # Creates a new user and encrypts the plaintext password
 u = User.new( {email: 'email@example.com', password: 'plainText'})

 # Create a new user and save (insert) into database
 u1 = User.new( {email: 'email@example.com', password: 'plainText'}).insert()

 # get Email or User of this object is simple as using the fields of the object
 u1.email # returns email@example.com

 u1.password # returns $2a$10$NyxVqdcX8gD4a1kuFhoRuO6ZiH6sklRjFYjAywWllbW7HZ910FgFm

 # Retrieve a User from the Database and return a user object
 u2 = User.new().find_one( {email: 'email4@example.com'} )

 # Remove a user (or any other object from a collection) ex:
 r = User.new({_id: '569809fda2dc7acb80000000'}).remove_one()

# Update a User by an email address
# If no key is passed in (1st param to `update()`) then Api will use internal @id
# When updating, an @id must already exist (since the doc was created & saved to DB)
u = User.new().update({email: 's@s'}, {email: 's@m'})

# Remove a user (or any other object from a collection) ex:
r = User.new({_id: '569809fda2dc7acb80000000'}).remove_one()

# Update a User by an email address
# If no key is passed in (1st param to `update()`) then Api will use internal @id
# When updating, an @id must already exist (since the doc was created & saved to DB)
u = User.new({email: 's@s'}).update({}, {email: 's@m'})
```

* Sinatra - Ruby Framework
* gem install sinatra-contrib
* Mongo - MongoDB library
* [https://github.com/codahale/bcrypt-ruby] (bcrypt-ruby) -  same password library Devise and other Ruby authentication libraries use.
* [https://github.com/hassox/warden/wiki]) (Warden) -  # The same authentication library Devise and other Ruby authentication libraries use

## License

    Copyright [2015] [Sabelo Mhlambi]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License
