# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
  module Views
    module Players
  
      # Player profile view class.
      class Profile < Layout
        
        def player
          @player || nil
        end
        
      end
    
    end
  end
end