# @author Daniel Thorpe dan@blindingskies.com
# @date 11/12/2011

require './Models/Person.rb'

# An extensible Pool Game class.
# 
# This is very simple. Create the game, and then add
# players to either the breaking team, or the other team.
# Call, `endGame` asserting whether the breaking team won
# or not, and optionally, include whether the game was won
# due to a foul on the back
class Game

  def initialize(doc=nil)
    @doc = doc if doc != nil
    @breakingTeam = Array.new
    @otherTeam = Array.new
  end

  # Use define_method for accessing the underlying CouchDB attributes
  %w(_id date breakingTeamWon).each do | method |
    define_method(method) { @doc[method.to_s] }
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
  
# @todo Needs methods to get the player objects  
  
  
end