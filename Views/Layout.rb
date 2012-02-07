# @author Rowan Manning info@rowanmanning.co.uk
# @date 12/12/2011

class PoolScoring
    module Views
    
        # This is the class extended by all other application
        # views. The main purpose of this is to provide defaults
        # for the common view parameters as well as common view
        # functionality.
        class Layout < Mustache
      
            # Page title.
            def title
                @title || 'Untitled'
            end
      
            # Page title (full with site suffix).
            def fullTitle
                title + ' : Pool Scoring'
            end
            
            # Page meta description.
            def description
                @description || ''
            end
            
            # The current HTTP request.
            def request
                @request
            end
            
            # The current time.
            def now
                Time.now
            end
            
            # Any user-generated errors that should be presented.
            # For example, after a failed POST request.
            def errors
                @errors || Array.new
            end
            
            # Whether any user-generated errors are present.
            def hasErrors?
                self.errors.size > 0
            end
      
        end
    
    end
end