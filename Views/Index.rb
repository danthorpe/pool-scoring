# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
    module Views
    
        # Index view class.
        class Index < Layout
            
            # Recent games.
            def games
                @games || Array.new
            end
            
            # Current star player.
            def starPlayer
                @starPlayer || nil
            end
            
            # Newest recruit.
            def newRecruit
                @newRecruit || nil
            end
            
        end
    
    end
end