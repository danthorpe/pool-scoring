# @author Daniel Thorpe dan@blindingskies.com
# @date 11/12/2011

# Dependencies
require './Controllers/CouchDB.rb'
require './Models/Person.rb'

# An extensible Pool Game class.
# 
# This is Very simple. Create the game, and then add
# players to either the breaking team, or the other team.
# Call, `endGame` asserting whether the breaking team won
# or not, and optionally, include whether the game was won
# due to a foul on the back
class Game
    
    # Mixin CouchDB
    include CouchDB
    
    def initialize(doc=nil, server=nil)
        @doc = doc if doc != nil
        @server = server if server != nil
        @breakingTeam = Array.new
        @otherTeam = Array.new
    end

    # Use define_method for accessing the underlying CouchDB attributes
    %w(_id date breakingTeamWon foulOnBlack).each do | method |
        define_method(method) { @doc[method.to_s] }
    end
    
    # Get the game's date, formatted according to http://ruby-doc.org/core-1.9.3/Time.html#method-i-strftime
    # (as a lambda, mainly for use with Mustache)
    def dateFormatted
        lambda { |format = "%Y"|
            Time.parse(self.date).strftime(format)
        }
    end
    
    def breakingPlayers
        # Get all the documents
        docs = CouchRest.post(@server + "/#{CouchDB::DB}/_all_docs?include_docs=true", {:keys => @doc['breakingTeam']})
        # Create an empty array
        persons = Array.new
        docs["rows"].collect do |row| 
            person = Person.new(row["doc"], @server)
            persons.push person
        end
        return persons
    end

    def otherPlayers
        # Get all the documents
        docs = CouchRest.post(@server + "/#{CouchDB::DB}/_all_docs?include_docs=true", {:keys => @doc['otherTeam']})
        # Create an empty array
        persons = Array.new
        docs["rows"].collect do |row| 
            person = Person.new(row["doc"], @server)
            persons.push person
        end
        return persons
    end

    def winningPlayerIds
        if self.breakingTeamWon
            return @doc['breakingTeam']
        else
            return @doc['otherTeam']
        end    
    end
    
    def losingPlayerIds
        if self.breakingTeamWon
            return @doc['otherTeam']
        else
            return @doc['breakingTeam']
        end    
    end
    
    def winningPlayers
        if (self.breakingTeamWon)
            return self.breakingPlayers
        else
            return self.otherPlayers
        end    
    end
    
    def losingPlayers
        if (self.breakingTeamWon)
            return self.otherPlayers
        else
            return self.breakingPlayers
        end    
    end
    
    # Get player names as a neatly formatted string from an array of players.
    def getPlayerNames(players)
        playerNames = players.collect{|player| player.name }
        if playerNames.count == 1
            return playerNames[0]
        else
            lastPlayerName = playerNames.pop
            playerNames.join(', ') + ' & ' + lastPlayerName
        end
    end
    protected :getPlayerNames
    
    def winningPlayerNames
        self.getPlayerNames self.winningPlayers
    end
    
    def losingPlayerNames
        self.getPlayerNames self.losingPlayers
    end

    def addPlayerToBreakingTeam(player)
        @breakingTeam.push player
    end 
  
    def addPlayerToOtherTeam(player)
        @otherTeam.push player
    end 
  
    def endGame(didBreakingTeamWin, foulOnBlack=false)
        @endDate = Time.now
        @breakingTeamWon = didBreakingTeamWin
        @foulOnBlack = foulOnBlack
    end
  
    def document 
        return @doc if @doc != nil    
        doc = {:type => "Game", :date => @endDate, :breakingTeam => @breakingTeam.collect { |player| player._id }, :otherTeam => @otherTeam.collect { |player| player._id }, :breakingTeamWon => @breakingTeamWon, :foulOnBlack => @foulOnBlack}
        return doc    
    end
    
    def to_json
        @doc.to_json
    end

end