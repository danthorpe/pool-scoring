# @author Daniel Thorpe dan@blindingskies.com
# @date 11/12/2011

require './Models/Person.rb'

# An extensible Pool Game class.
# 
# This is Very simple. Create the game, and then add
# players to either the breaking team, or the other team.
# Call, `endGame` asserting whether the breaking team won
# or not, and optionally, include whether the game was won
# due to a foul on the back
class Game
  
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

    def breakingPlayers
        # Get all the documents
        docs = CouchRest.post(@server + "/#{CouchDB::DB}/_all_docs?include_docs=true", {:keys => @doc['breakingTeam']})
        # Create an empty array
        persons = Array.new
        docs["rows"].collect do |row| 
            person = Person.new row["doc"]
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
            person = Person.new row["doc"]
            persons.push person
        end
        return persons
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

>>>>>>> Stashed changes
end