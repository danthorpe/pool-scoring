# @author Rowan Manning info@rowanmanning.co.uk
# @date 13/12/2011

class PoolScoring
  module Views
    module Games
      
      # Games new view class.
      class New < Layout
        
        def players
          @players || Array.new
        end
        
      end
    
    end
  end
end