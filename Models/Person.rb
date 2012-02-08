# @author Daniel Thorpe dan@blindingskies.com
# @date 10/12/2011

# Dependencies
require './Controllers/CouchDB.rb'
require './Library/Gravatar.rb'

# Person class
class Person
    
    # Mixin CouchDB
    include CouchDB
    
    # Time durations for statistics
    STATS_SEVEN_DAY = "7 Day Statistics"
    STATS_ALL_TIME = "All Time Statistics"
    
    # Constructor
    # @param doc A CouchDB document representing the person
    # @param server A CouchDB server on which the document exists
    def initialize(doc=nil, server=nil)
        @doc = doc if doc != nil
        @server = server if server != nil
        @games = nil
    end
    
    # Use define_method for accessing the underlying CouchDB attributes
    %w(_id name email username).each do | method |
        define_method(method) { @doc[method.to_s] }
    end
    
    # Get the user's avatar at a specified size (as a lambda, mainly for use with Mustache)
    def avatarSize
        lambda { |size = 80|
            Gravatar.new self.email, size
        }
    end
    
    # Get the user's avatar (standard size - 80)
    def avatar
        avatarSize.call
    end
    
    # Is the user a guest?
    def guest?
        @doc['guest'] ? true : false
    end
    
    def to_s
        "(#{self.username}, #{self.email})"
    end
    
    def to_json
        @doc.to_json
    end

    def games(type = STATS_ALL_TIME, force = false)
        
        if force || @games == nil || @games[type] == nil

            # Define our key objects
            nSecsWeek = 604800            
            t = Time.now        
            t.utc
            
            startkey = Array.new
            startkey.push self._id
            startkey.push t.to_i                
            
            endkey = Array.new
            endkey.push self._id
            
            # Get all the games for the player
            if type == STATS_SEVEN_DAY            
                endkey.push t.to_i - nSecsWeek
            else
                endkey.push 0
            end
            
            req = @server + "/#{CouchDB::DB}/_design/Game/_view/byPlayerByDate?descending=true&startkey=#{URI.escape(startkey.to_json, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}&endkey=#{URI.escape(endkey.to_json, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

            # Get the response from CouchDB
            response = CouchRest.get req

            # Define an hash for Games
            @games = Hash.new if @games == nil
            @games[type] = Array.new
            response['rows'].each do |item|
                @games[type].push Game.new(item['value'], @server)
            end
        end

        # Return the game types
        return @games[type]
    end
    
    def recentGames(limit = 3)    
        return self.games.slice(0,3)    
    end
    
    # Player Statistics
    #
    # Call this method to retrieve the statistics for the person from Redis
    # If the statistics haven't already been calculated (for the calculate flag 
    # is set), then the stats will be recalculated and stored in Redis overwriting
    # the previous value.
    #
    # Calculating the statistics is a relatively expensive operation, because it 
    # requires extra HTTP calls to get the games from CouchDB
    def statistics(type = STATS_ALL_TIME, force = false)

        # Check Redis for the stats
        store = Redis.new
        
         # Get the object for the player from Redis
         # or a new Hash if it doesn't exist
         if force || store[self.username] == nil
             playerStats = Hash.new
         else
            playerStats = JSON.parse(store.get(self.username))
        end

        if force || playerStats[type] == nil
            
            # Get the games for this time duration
            games = self.games(type, force)

            # Create a hash to store statistics in
            stats = Hash.new
            stats[:points] = 0
            stats[:wins] = 0
            stats[:losses] = 0

            games.each do |game|
                # Get the points for the player earnt for the game
                points = game.pointsForPlayer(self._id)
                if points != 0
                    stats[:points] += points
                    if points > 0
                        stats[:wins] += 1
                    else
                        stats[:losses] += 1
                    end
                end
            end

            stats[:percentage] = (stats[:wins].to_f / (stats[:wins] + stats[:losses])) * 100

            # Update the stats object
            playerStats[type] = stats

            # Save the stats in Redis
            store.set self.username, playerStats.to_json
        end
        
        # Return the stats object
        return playerStats[type]
    end
    
    # Basic player statistics
    def stats
        if @stats == nil

            # Store simple statistical measures in a hash
            @stats = Hash.new
            
            # Get the player's games
            allGames = self.games
            
            # We only calculate stats over a rolling 7 day period
            nSecsWeek = 604800            
            t = Time.now        
            t.utc
            minimunDateTimestamp = t.to_i - nSecsWeek

            games = allGames.select do |game|
                game.date > minimunDateTimestamp
            end
            
            # Number of games played in total
            @stats[:total] = games.count
            @stats[:wins] = 0
            @stats[:losses] = 0
            @stats[:percentage] = 0
             
            # Count the number of wins/losses
            games.each do |game|
                if game.winningPlayerIds.include? self._id
                    @stats[:wins] += 1
                else
                    @stats[:losses] += 1
                end
            end
            
            # Calculate the percentage wins
            if @stats[:total] != 0
                @stats[:percentage] = ((@stats[:wins].to_f / @stats[:total].to_f).to_f * 100).to_i
            end

        end

        return @stats
    end

    # Player statistics
    def numberOfWins
        return self.stats[:wins]
    end

    def numberOfLosses
        return self.stats[:losses]
    end

    def winPercentage
        return self.stats[:percentage]
    end
    
    def winPercentageRounded
        percentage = self.stats[:percentage]
        if percentage != nil
            return percentage.round
        else
            return 0
        end
    end

    def lossPercentage
        return 100 - self.stats[:percentage]
    end
    
    def lossPercentageRounded
        lossPercentage = self.lossPercentage
        if lossPercentage != nil
            return lossPercentage.round
        else
            return 0
        end
    end

end