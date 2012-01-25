# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
    module Views
        module Players
        
            # Player versus view.
            class Vs < Layout
            
                def primary
                    @primary || nil
                end
                
                def secondary
                    @secondary || nil
                end
                
                def games
                    @games || Array.new
                end
            
            end
        
        end
    end
end