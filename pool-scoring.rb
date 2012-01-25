require 'json/ext'
require 'sinatra/base'
require 'sinatra/multi_route'
require 'couchrest'
require 'mustache/sinatra'

require './Models/Person.rb'
require './Models/Game.rb'

require './Controllers/PlayerController.rb'
require './Controllers/GameController.rb'

class PoolScoring < Sinatra::Base
    
    # Register sinatra multi-routes
    register Sinatra::MultiRoute
    
    # Register mustache and initialise the Views module - Mustache requires this
    register Mustache::Sinatra
    module Views end
  
    # Define which CouchDB instance to use.
    if ENV['CLOUDANT_URL']
        set :couchdb, ENV['CLOUDANT_URL']
    else
        set :couchdb, 'http://poolscoring:yourmum@localhost:5984'
    end

    set :root, File.dirname(__FILE__)
    set :public_folder, './Public'
    set :static, true
    set :mustache, {
        :views => './Views',
        :templates => './Templates'
    }

    # Index page.
    get '/' do
        gc = GameController.new settings.couchdb
        @games = gc.recent 3
        pc = PlayerController.new settings.couchdb
        @starPlayer = pc.star
        @newRecruit = pc.newest
        @title = 'Welcome!'
        mustache :'index'
    end
  
    # Rules page.
    get '/rules' do
        @title = 'House Rules'
        mustache :'rules/index'
    end
    
    # Style-guide page.
    get '/styleguide' do
        @title = 'Style-Guide'
        mustache :'styleguide/index'
    end

    # All players page.
    get '/players' do
        @title = 'Players'
        pc = PlayerController.new settings.couchdb
        @players = pc.all
        mustache :'players/index'
    end
    
    # Create players page.
    route :get, :post, '/player/new' do
        
        # POST
        @errors = Array.new
        if request.request_method == 'POST'
            
            # Create a player controller
            pc = PlayerController.new settings.couchdb
            
            # Check to see if the name is set
            if !params['name'] || params['name'] == ''
                @errors.push "Name is a required field."
            
            # Check to see if the name is valid
            elsif !params['name'].match(/^.{1,60}$/i)
                @errors.push "That's a bit long for a name, isn't it?"
            end
            
            # Check to see if the username is set
            if !params['username'] || params['username'] == ''
                @errors.push "Username is a required field."
                
            # Check to see if the username is valid
            elsif !params['username'].match(/^[a-z0-9\_]{3,20}$/i)
                @errors.push "Usernames must be alphanumeric with underscores, and between 3 and 20 characters in length. Please enter a valid username."
                
            # Check to see if the username is taken
            elsif !pc.isUsernameAvailable params['username']
                @errors.push "The username '#{ params['username'] }' has been taken already. Please try another one."
            end
            
            # Check to see if the email is set
            if !params['email'] || params['email'] == ''
                @errors.push "Email Address is a required field."
            
            # Check to see if the email is valid... Actually, you know what? I can't be bothered right now...
            elsif false
                @errors.push "Please enter a valid email address."
            
            # Check to see if the email is taken
            elsif !pc.isEmailAvailable params['email']
                @errors.push "The email address '#{ params['email'] }' has been registered to another user. Please try another one."
            end
            
            # All OK then!
            if @errors.size == 0
                
                # a little sanitisation
                params['username'].downcase!
                params['email'].downcase!
                
                if pc.createPlayer params
                    redirect to("/player/#{ params['username'] }")
                else
                    @errors.push 'Something broke... Blame Dan.'
                end
            end
            
        end
                
        # GET
        @title = 'Create a Player'
        mustache :'players/new'
        
    end

    # Single player profile.
    get '/player/:username' do
        pc = PlayerController.new settings.couchdb
        @player = pc.playerWithUsername params[:username]
        @title = @player.name if @player != nil
        mustache :'players/profile'
    end

    # Player vs Player statistics
    get '/player/:primary/:secondary' do
        # Get the two players from the player controller
        pc = PlayerController.new settings.couchdb
        @primary = pc.playerWithUsername params[:primary]
        @secondary = pc.playerWithUsername params[:secondary]
        gc = GameController.new settings.couchdb
        @games = gc.gamesBetweenPlayers(@primary, @secondary)
        
        # These are the games between the primary and secondary players.
        # Should probably generate more interesting statistics, but for 
        # now can just list the games.
        
    end
    
    # Recent games page.
    get '/games' do
        @title = 'Recent Games'
        gc = GameController.new settings.couchdb
        @games = gc.recent 8
        mustache :'games/index'
    end
    
    # Record a game
    get '/game/new' do
        @title = 'Record a Game'
        pc = PlayerController.new settings.couchdb
        @players = pc.all
        mustache :'games/new'
    end  
    post '/game/new' do
        # Create a Game Controller
        gc = GameController.new settings.couchdb
        # Record this game
        @game = gc.record params
        redirect to("/game/#{@game._id}")
    end

    # Display a game
    get '/game/:gameId' do
        # Create a Game Controller
        gc = GameController.new settings.couchdb
        # Get the game
        @game = gc.byId params[:gameId]
        @title = 'Game at ' + @game.dateFormatted.call('%l:%M%P on %B %d, %Y');
        # Do something with the game
        mustache :'games/game'
    end
    
    # The Leaderboard
    get '/leaderboard' do
        @title = 'Leaderboard'
        # Create a Player Controller
        pc = PlayerController.new settings.couchdb
        @leaderboard = pc.leaderboard
        mustache :'leaderboard/index'
    end
    
    # 404 page
    not_found do
        @title = 'Not Found'
        mustache :'errors/error404'
    end

end
