# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
    module Views
        module Players
      
            # Players index view class.
            class Index < Layout
            
                def players
                    @players || Array.new
                end
            
            end
    
        end
    end
end