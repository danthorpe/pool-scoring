# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
  module Views
  
    # Players view class
    class Players < Layout
      
      def players
        @players || Array.new
      end
      
    end
    
  end
end