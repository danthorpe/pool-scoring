# @author Rowan Manning info@rowanmanning.co.uk
# @date 24/01/2012

# Dependencies
require 'mustache'

# TrashTalk class. Used to provide random "trash talk" descriptions
# of game outcomes
class TrashTalk
    
    # Game descriptions class variable.
    @@descriptions = [
        "{{winners}} beat {{losers}}",
        "{{winners}} kicked {{losers}}'s ass",
        "{{winners}} wiped the floor with {{losers}}",
        "{{winners}} ate {{losers}} for breakfast",
        "{{winners}} made {{losers}} cry like a little girl",
        "{{winners}} took down {{losers}}",
        "{{winners}} hung {{losers}} out to dry",
        "{{winners}} showed {{losers}} who's boss"
    ]
    
    # Team game descriptions class variable.
    @@teamDescriptions = [
        "{{winners}} beat {{losers}}",
        "{{winners}} kicked {{losers}}'s asses",
        "{{winners}} wiped the floor with {{losers}}",
        "{{winners}} ate {{losers}} for breakfast",
        "{{winners}} made {{losers}} cry like little girls",
        "{{winners}} took down {{losers}}",
        "{{winners}} hung {{losers}} out to dry",
        "{{winners}} showed {{losers}} who's boss"
    ]
    
    # Protected methods
    protected
    
        # Join together an array of names into a string.
        # @param names The names to join.
        def joinNames(names)
            if names.count == 1
                return names[0]
            else
                lastName = names.pop
                return names.join(', ') + ' and ' + lastName
            end
        end
        
        # Get a random game description
        def randomDescription
            set = @isTeams ? @@teamDescriptions : @@descriptions
            template = set[rand(set.size)]
            Mustache.render template, {:winners => self.getWinnerNames, :losers => self.getLoserNames}
        end
    
    # Public methods
    public
    
        # Class constructor.
        # @param winnerNames The game winners as an array of names.
        # @param loserNames The game losers as an array of names.
        def initialize(winnerNames, loserNames)
            @winnerNames, @loserNames = winnerNames, loserNames
            @isTeams = winnerNames.count > 1 || loserNames.count > 1
        end
        
        # Get the winner names as a string.
        def getWinnerNames
            self.joinNames @winnerNames
        end
        
        # Get the loser names as a string.
        def getLoserNames
            self.joinNames @loserNames
        end
        
        # To-string
        def to_s
            self.randomDescription
        end

end