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

  def initialize
    @breakingTeam = Array.new
    @otherTeam = Array.new
  end

  def addPersonToBreakingTeam(player)
    @breakingTeam.push player
  end 
  
  def addPersonToOtherTeam(player)
    @otherTeam.push player
  end 
  
  def endGame(didBreakingTeamWin, foulOnBlack=false)
    @breakingTeamWon = didBreakingTeamWin
    @foulOnBlack = foulOnBlack
  end
  
  def document    
    doc = {:type => "Game", :date => Time.now, :breakingTeam => @breakingTeam.collect { |player| player._id }, :otherTeam => @otherTeam.collect { |player| player._id }, :breakingTeamWon => @breakingTeamWon, :foulOnBlack => @foulOnBlack}
    return doc    
  end
  
end