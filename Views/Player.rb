# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
  module Views
  
    # Player view class.
    class Player < Layout
      
      def player
        @player || nil
      end
      
    end
    
  end
end