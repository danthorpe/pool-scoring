# @author Daniel Thorpe dan@blindingskies.com
# @date 18/12/2011

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
    # This uses the `all` view in the Game design 
    # document on the database, which is:
    #  
    #  function(doc) {
    #    if (doc.type == "Game") {
    #      emit([doc.date, doc._id], doc);
    #    }
    #  }
    #
    def all
    
        # Define an array for games
        games = Array.new
        
        # Get all the games
        result = CouchRest.get @server + "/#{CouchDB::DB}/_design/Game/_view/all?descending=true"
        
        # Iterate through the game and create Game objects
        result['rows'].each do |row|    
            games.push Game.new(row['value'], @server)
        end
        
        return games
    end
    
    # Get recent games.
    def recent(limit = 10)
        
        # Sanitise the limit
        limit = limit.to_i
        
        # Define an array for games
        games = Array.new
        
        # Get the games
        result = CouchRest.get @server + "/#{CouchDB::DB}/_design/Game/_view/all?descending=true&limit=" + limit.to_s
        
        # Iterate through the game and create Game objects
        result['rows'].each do |row|    
            games.push Game.new(row['value'], @server)
        end
        
        return games
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