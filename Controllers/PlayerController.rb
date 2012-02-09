# @author Daniel Thorpe dan@blindingskies.com
# @date 18/12/2011

require './Controllers/CouchDB.rb'
require './Controllers/GameController.rb'
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
    def all(orderByName = false)
        
        # Define an array for people
        people = Array.new
        
        # Get all the players
        if orderByName
            req = @server + "/#{CouchDB::DB}/_design/Person/_view/byName"
        else
            req = @server + "/#{CouchDB::DB}/_design/Person/_view/all"
        end
        
        # Execute the request
        result = CouchRest.get req
        
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

    # Get the player leaderboard
    #
    # Store the leaderboard in Redis
    # Calculate it using Game objects from CouchDB
    def leaderboard(type = Person::STATS_ALL_TIME, force = false)

        # Get our Redis store
#        store = Redis.new

        # Define the key
        key = "Leaderboard " + type
        
        # Get the value from Redis
        val = nil #store.get(key)
        
        # Get the object for the player from Redis
        # or a new Hash if it doesn't exist
        if force || val == nil

            # Get all the games in the given time window
            if type == Person::STATS_SEVEN_DAY            
            
                # Define our key objects
                nSecsWeek = 604800            
                t = Time.now        
                t.utc
                
                startkey = t.to_i
                endkey = t.to_i - nSecsWeek
                
                # We can't compute these stats in CouchDB, because we can't
                # reduce on a filtered view. Therefore we have to calculate the
                # stats here.
                
                # Get the games from the Game Controller
                gc = GameController.new @server                
                games = gc.all(type)

                # Create storage to calculate the stats in
                stats = Hash.new
                
                # Define a lambda to initialize a new hash for statistics
                initStatsHash = ->{ 
                    {:points => 0, :wins => 0, :losses => 0}
                }
                
                # Iterate through the games
                games.each do |game| 
                    # Get the winners
                    playerIds = game.playerIds
                    # Calculate the stats for each player in the game
                    playerIds.each do |playerId|
                        # Check to see if we've created stats before
                        if ! stats.has_key?(playerId)
                            # Create a new hash for statistics
                            stats[playerId] = initStatsHash.call()
                        end
                        
                        # Get the points for the player earnt for the game
                        points = game.pointsForPlayer(playerId)
                        if points != 0
                            stats[playerId][:points] += points
                            if points > 0
                                stats[playerId][:wins] += 1
                            else
                                stats[playerId][:losses] += 1
                            end
                        end
                    end
                end
                
                # Turn this into an array
                results = stats.each { |key,value|
                    value[:playerId] = key
                }.values
                                
                # Now update the percentages
                results.each do |stats|
                    stats[:percentage] = (stats[:wins].to_f / (stats[:wins] + stats[:losses])) * 100                
                end

                # Now we need to sort it
                leaderboard = results.sort_by { |item|
                    # This sorts everyone with out a single win to the bottom, then by points, descending, and by wins descending
                    [item[:wins] == 0 ? 1 : 0, -item[:points], -item[:wins]]
                }.enum_for(:each_with_index).collect { |item, i|
                    {:person => self.byId(item[:playerId]), :rank => item, :position => i + 1}
                }

                
            else

                # Create a request
                req = @server + "/#{CouchDB::DB}/_design/Game/_view/leaderboard?group_level=1"

                # Get the response from CouchDB
                response = CouchRest.get req

                # Sort the results
                leaderboard = response['rows'].sort_by { |item|
                    # This sorts everyone with out a single win to the bottom, then by points, descending, and by wins descending
                    [item['value']['wins'] == 0 ? 1 : 0, -item['value']['points'], -item['value']['wins']]
                }.enum_for(:each_with_index).collect { |item, i|
                    {:person => self.byId(item['key'][0]), :rank => item['value'], :position => i + 1}
                }
                                                
            end

            # Save the leaderboard in redis
#            store.set key, leaderboard.to_json

        elsif val != nil
            # Parse the leaderboard out of redis
            leaderboard = JSON.parse(val)
        end

        # Return the leaderboard
        return leaderboard
    end


    # Get the leaderboard
    #
    # This gets a leaderboard of players
    def oldLeaderboard        
        # Get the key/values
        req = @server + "/#{CouchDB::DB}/_design/Game/_view/leaderboard?group_level=1"
        result = CouchRest.get req

        # Sort the objects        
        return result['rows'].sort_by { |item|
            [-item['value']['points'], -item['value']['wins'], item['value']['losses']]
        }.enum_for(:each_with_index).collect { |item, i|
            {:person => self.byId(item['key'][0]), :rank => item['value'], :position => i + 1}
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