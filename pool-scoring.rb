require 'json/ext'
require 'sinatra/base'
require 'couchrest'
require 'mustache/sinatra'

require './Models/Person.rb'
require './Models/Game.rb'

require './Controllers/PlayerController.rb'
require './Controllers/GameController.rb'

class PoolScoring < Sinatra::Base
  
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
        @title = 'Welcome!'
        mustache :'index'
    end
  
    # Style-guide page - temporary.
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
    get '/player/new' do
        @title = 'Create a Player'
        mustache :'players/new'
    end
    post '/player/new' do
        # Create a player controller
        pc = PlayerController.new settings.couchdb    
        # Check to see if the username & email are taken
        if !pc.isUsernameAvailable params['username']
            body "#{params['username']} is taken"
            status 400
            return
        elsif !pc.isEmailAvailable params['email']
            body "#{params['email']} is taken"
            status 400
            return
        else
            @player = pc.createPlayer params
            redirect to("/player/#{@player.username}")
        end
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
        # Do something with the game
        mustache :'games/game'
    end
    
    # The Leaderboard
    get '/leaderboard' do
        @title = 'Leaderboard'
        # Create a Player Controller
        pc = PlayerController.new settings.couchdb
        leaderboard = pc.leaderboard
        mustache :'leaderboard/index'
    end

end
