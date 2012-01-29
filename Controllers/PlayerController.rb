# @author Daniel Thorpe dan@blindingskies.com
# @date 18/12/2011

require './Controllers/CouchDB.rb'
require './Models/Person.rb'

# Player Controller
# 
# A simple controller object to encapsulate functionality
# for dealing with Players, which are Person objects.
class PlayerController

    # Mixin CouchDB
    include CouchDB
    
    # Constructor
    # @param url The url of the CouchDB server
    def initialize(url)
        @server = url
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
        result = CouchRest.get  @server + "/#{CouchDB::DB}/_design/Person/_view/all"
        
        # Iterate through the people and create Person objects
        result['rows'].each do |row|    
            people.push Person.new(row['value'], @server)
        end
        
        return people    
    end
    
    # Get a player by identifier
    #
    # This just gets the document and uses it to create
    # a new Player object.
    def byId(identifier)
        doc = CouchRest.get @server + "/#{CouchDB::DB}/#{identifier}"
        return Person.new(doc, @server)
    end


    # Get the leaderboard
    #
    # This gets a leaderboard of players
    def leaderboard        
        # Get the key/values
        req = @server + "/#{CouchDB::DB}/_design/Game/_view/pointsLeaderboard?group=true"
        result = CouchRest.get req

        # Sort the objects        
        return result['rows'].sort_by { |item|
            [-item['value']['score'], -item['value']['points'], -item['value']['wins'], item['value']['losses']]
        }.enum_for(:each_with_index).collect { |item, i|
            {:person => self.byId(item['key']), :rank => item['value'], :position => i + 1}
        }
    end

    # Get the current star player
    #
    # This gets a single player
    def star
        leaderboard = self.leaderboard
        return leaderboard[0] ? leaderboard[0][:person] : nil
    end

    # Get the newest player
    #
    # This gets a single player
    def newest
        # Get the newest players
        req = @server + "/#{CouchDB::DB}/_design/Person/_view/byDate?descending=true&limit=1"
        result = CouchRest.get req
        if result["rows"].length == 1
            return Person.new(result['rows'][0]['value'], @server)
        else
            return nil
        end
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
        result = CouchRest.get  @server + "/#{CouchDB::DB}/_design/Person/_view/byUsername?key=%22#{username}%22"
        if result["rows"].length == 1
            return Person.new(result['rows'][0]['value'], @server)
        else
            return nil
        end
    end

    # Get a specific player using an email
    # 
    # This uses the `byEmail` view in the Person design
    # document on the database, which is:
    #
    #  function(doc) {
    #    if (doc.type == "Person") {
    #      emit(doc.email, doc);
    #    }
    #  }
    #
    def playerWithEmail(email)
        result = CouchRest.get  @server + "/#{CouchDB::DB}/_design/Person/_view/byEmail?key=%22#{email}%22"
        if result["rows"].length == 1
            return Person.new(result['rows'][0]['value'], @server)
        else
            return nil
        end
    end
  

    # Check to see if the username is available
    def isUsernameAvailable(username)
        player = self.playerWithUsername username
        return player == nil
    end
  
    # Check to see if the email is available
    def isEmailAvailable(email)
        player = self.playerWithEmail email
        return player == nil
    end

    # Create a new player
    def createPlayer(params)
    
        # Create a hash
        doc = {:type => "Person"}
        
        # Set the name
        doc[:name] = params["name"]
        
        # Set the email
        doc[:email] = params["email"]
        
        # Set the username
        doc[:username] = params["username"]
        
        # Set the guest flag
        doc[:guest] = params["guest"] ? true : false
        
        # Set the current date
        doc[:date] = Time.now.to_i
        
        # Get a new id from the CouchDB server
        uuid = CouchDB.nextUUID @server
        doc[:_id] = uuid
        
        # Put it to the database
        response = CouchRest.put @server + "/#{CouchDB::DB}/#{uuid}", doc
        
        return response != false
    
    end

end