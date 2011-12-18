# @author Daniel Thorpe dan@blindingskies.com
# @date 18/12/2011

require './Models/Person.rb'

# Player Controller
# 
# A simple controller object to encapsulate functionality
# for dealing with Players, which are Person objects.
class PlayerController

  # Constructor
  # @param db The url of a CouchDB database
  def initialize(db)
    @db = db
  end

  # All players currently on the database
  #
  # This uses the `all` view in the Person design 
  # document on the database, which is:
  #  
  #  function(doc) {
  #    if (doc.type == "Person") {
  #      emit([doc.username, doc._id], doc);
  #    }
  #  }
  #
  def all

    # Define an array for people
    people = Array.new
  
    # Get all the players
    result = CouchRest.get @db + '/_design/Person/_view/all'

    # Iterate through the people and create Person objects
    result['rows'].each do |row|    
      people.push Person.new row['value']
    end

    return people    
  end


  # Get a specific player using a username
  # 
  # This uses the `byUsername` view in the Person design
  # document on the database, which is:
  #
  #  function(doc) {
  #    if (doc.type == "Person") {
  #      emit(doc.username, doc);
  #    }
  #  }
  #
  def playerWithUsername(username)
    result = CouchRest.get @db + '/_design/Person/_view/byUsername?key=%22' + username + '%22'
    return Person.new result['rows'][0]['value']
  end


end