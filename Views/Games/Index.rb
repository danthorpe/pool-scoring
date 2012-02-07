# @author Rowan Manning info@rowanmanning.co.uk
# @date 15/01/2011

class PoolScoring
    module Views
        module Games
      
            # Games index view class.
            class Index < Layout
            
                def games
                    @games || Array.new
                end
            
            end
    
        end
    end
end