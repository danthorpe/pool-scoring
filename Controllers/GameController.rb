# @author Daniel Thorpe dan@blindingskies.com
# @date 18/12/2011

require 'redis'

require './Controllers/CouchDB.rb'
require './Controllers/PlayerController.rb'
require './Models/Game.rb'

# Game Controller
# 
# A simple controller object to encapsulate functionality
# for dealing with Players, which are Person objects.
class GameController

    # Mixin CouchDB
    include CouchDB
  
    # Constructor
    # @param url The url of the CouchDB server
    def initialize(url)
        @server = url
    end

    # All games currently on the database
    #
    # This uses the `byDate` view in the Game design 
    # document on the database, which is:
    #  
    #  function(doc) {
    #    if (doc.type == "Game") {
    #      emit(doc.date, doc);
    #    }
    #  }
    # @param type to specify the date range given the constants
    # @param to force retrieval
    def all(type = Person::STATS_ALL_TIME, force = false)
    
        if force || @games == nil || @games[type] == nil

            # Define our key objects
            nSecsWeek = 604800            
            t = Time.now        
            t.utc
            
            startkey = t.to_i
            endkey = 0
            
            # Get all the games for the player
            if type == Person::STATS_SEVEN_DAY            
                endkey = t.to_i - nSecsWeek
            end
            
            req = @server + "/#{CouchDB::DB}/_design/Game/_view/byDate?descending=true&startkey=#{URI.escape(startkey.to_json, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}&endkey=#{URI.escape(endkey.to_json, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

            # Get the response from CouchDB
            response = CouchRest.get req

            # Define an hash for Games
            @games = Hash.new if @games == nil
            @games[type] = Array.new
            response['rows'].each do |item|
                @games[type].push Game.new(item['value'], @server)
            end
        end

        # Return the games
        return @games[type]
    end
    
    # Get recent games.
    def recent(limit = 10)
        
        # Sanitise the limit
        limit = limit.to_i
        
        # Slice the games
        return self.all.slice(0, limit)
    end

    # Get a game by identifier
    #
    # This just gets the document and uses it to create
    # a new Game object.
    def byId(identifier)
        doc = CouchRest.get @server + "/#{CouchDB::DB}/#{identifier}"
        return Game.new(doc, @server)
    end

    # Get the games between two players
    #
    # This makes use of a CouchDB view 
    def gamesBetweenPlayers(a, b)

        # Get all the games for player A
        responseForA = CouchRest.get @server + "/#{CouchDB::DB}/_design/Game/_view/byPlayer?key=%22" + a._id + "%22"
        gamesForA = responseForA['rows'].collect do |item|
            item['value']
        end

        # Get all the games for player B
        responseForB = CouchRest.get @server + "/#{CouchDB::DB}/_design/Game/_view/byPlayer?key=%22" + b._id + "%22"
        gamesForB = responseForB['rows'].collect do |item|
            item['value']
        end

        # We just need to union these two results now.
        gameDocs = gamesForA & gamesForB

        # Create Game objects
        games = Array.new
        
        gameDocs.each do |doc|
            games.push Game.new(doc, @server)
        end

        return games
    end

    # Record a new game
    def record(params)
        
        # Create a player controller
        pc = PlayerController.new @server
        
        # Create a game
        game = Game.new
        
        # Make sure we have an array of breaking players
        if not params["breaking-player"].kind_of? Array
            params["breaking-player"] = [params["breaking-player"]];
        end
        
        # Get the breaking players
        for player in params["breaking-player"] do
            playerModel = pc.playerWithUsername player
            game.addPlayerToBreakingTeam playerModel
        end
        
        # Make sure we have an array of other players
        if not params["other-player"].kind_of? Array
            params["other-player"] = [params["other-player"]];
        end
        
        # Get the other players
        for player in params["other-player"] do
            playerModel = pc.playerWithUsername player
            game.addPlayerToOtherTeam playerModel
        end
        
        # What was the result?
        if params["breaking-player-won"] == "1"    
            breakingDidWin = true
        else
            breakingDidWin = false
        end
        
        if params.has_key? "foul-on-black"
            foulOnBlack = true
        else
            foulOnBlack = false
        end
        
        # End the game
        game.endGame(breakingDidWin, foulOnBlack)
        
        # Get the game as a document
        doc = game.document
        
        # Get a new id from the CouchDB server
        uuid = CouchDB.nextUUID @server
        doc[:_id] = uuid
        
        # Put it to the database
        CouchRest.put @server + "/#{CouchDB::DB}/#{uuid}", doc
        
        # Return a Game object from the document
        doc = CouchRest.get @server + "/#{CouchDB::DB}/#{uuid}"
        return Game.new(doc, @server)    
    end
end