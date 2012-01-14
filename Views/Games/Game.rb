# @author Rowan Manning info@rowanmanning.co.uk
# @date 13/12/2011

class PoolScoring
    module Views
        module Games
      
            # Games game view class.
            class Game < Layout
            
                def game
                    @game || nil
                end
            
            end
        
        end
    end
end