# @author Daniel Thorpe dan@blindingskies.com
# @date 10/12/2011

# Dependencies
require './Controllers/CouchDB.rb'
require './Library/Gravatar.rb'

# Person class
class Person
    
    # Mixin CouchDB
    include CouchDB
    
    # Constructor
    # @param doc A CouchDB document representing the person
    # @param server A CouchDB server on which the document exists
    def initialize(doc=nil, server=nil)
        @doc = doc if doc != nil
        @server = server if server != nil
    end
    
    # Use define_method for accessing the underlying CouchDB attributes
    %w(_id name email username).each do | method |
        define_method(method) { @doc[method.to_s] }
    end
    
    # Get the user's avatar at a specified size (as a lambda, mainly for use with Mustache)
    def avatarSize
        lambda { |size = 80|
            Gravatar.new self.email, size, 'unicorn'
        }
    end
    
    # Get the user's avatar (standard size - 80)
    def avatar
        avatarSize.call
    end
    
    def to_s
        "(#{self.username}, #{self.email})"
    end
    
    def to_json
        @doc.to_json
    end

    def games
        
        # Get all the games for the player
        response = CouchRest.get @server + "/#{CouchDB::DB}/_design/Game/_view/byPlayer?key=%22" + self._id + "%22"
        
        # Define an array for Games
        games = Array.new
        response['rows'].each do |item|
            games.push Game.new(item['value'], @server)
        end
        
        return games
    end
    
    # Basic player statistics
    def stats
        # Store simple statistical measures in a hash
        stats = Hash.new
        
        # Get the player's games
        games = self.games
        
        # Number of games played in total
        stats[:total] = games.count
        stats[:wins] = 0
        stats[:losses] = 0
        stats[:percentage] = 0
         
        # Count the number of wins/losses
        games.each do |game|
            if game.winningPlayerIds.include? self._id
                stats[:wins] += 1
            else
                stats[:losses] += 1
            end
        end
        
        # Calculate the percentage wins
        if stats[:total] != 0
            stats[:percentage] = ((stats[:wins].to_f / stats[:total].to_f).to_f * 100).to_i
        end

        return stats
    end

end