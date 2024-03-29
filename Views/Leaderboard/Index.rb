# @author Rowan Manning info@rowanmanning.co.uk
# @date 14/01/2011

class PoolScoring
    module Views
        module Leaderboard

            # Leaderboard index view class.
            class Index < Layout

                def leaderboard
                    @leaderboard || Array.new
                end

            end

        end
    end
end