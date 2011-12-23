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
    result = CouchRest.get @server + "/#{CouchDB::DB}/_design/Game/_view/all"

    # Iterate through the game and create Game objects
    result['rows'].each do |row|    
      people.push Game.new row['value']
    end

    return game
  end



  # Record a new game
  def record(params)
    
    # Create a player controller
    pc = PlayerController.new @server
    
    # Create a game
    game = Game.new
        
    # Get the breaking player
    player = pc.playerWithUsername params["breaking-player"]
    game.addPlayerToBreakingTeam player
    
    # Get the other player
    player = pc.playerWithUsername params["other-player"]
    game.addPlayerToOtherTeam player
    
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
    return Game.new CouchRest.get @server + "/#{CouchDB::DB}/#{uuid}"    

  end

end