require 'json/ext'
require 'sinatra/base'
require 'couchrest'

require './Models/Person.rb'
require './Models/Game.rb'

class PoolScoring < Sinatra::Base
<<<<<<< Updated upstream

  # Define which CouchDB instance to use.
  if ENV['CLOUDANT_URL']
    set :db, ENV['CLOUDANT_URL'] + '/poolscoring'
  else
    set :db, 'http://localhost:5984/poolscoring'
  end

  set :root, File.dirname(__FILE__)
  set :public_folder, 'public'
  set :static, true


  def players

    # Define an array for people
    people = Array.new
  
    # Get all the players
    result = CouchRest.get settings.db + '/_design/Person/_view/all'

    # Iterate through the people and create Person objects
    result['rows'].each do |row|    
      people.push Person.new(row['value'])
    end

    return people
  end

  def playerWithUsername(username)

    # Get all the players
    result = CouchRest.get(settings.db + '/_design/Person/_view/byUsername?key=%22' + username + '%22')
    return Person.new result['rows'][0]['value']
  end

  # Index page
  get '/' do
    "Welcome to pool scoring, make this pretty."
  end

  # Index page
  get '/players' do

    # Get all the players    
    players = self.players
    players.to_s

  end

  get '/player/:username' do
    
    # Get the Person object
    person = self.playerWithUsername params[:username]
    person.to_json
  end


  # Add a new game
  get '/new' do
  
    # Create a new game
    game = Game.new
    
    # Get some people
    rowan = self.playerWithUsername("rowan")
    dan = self.playerWithUsername("daniel")
    
    # Add them to the teams
    game.addPersonToBreakingTeam(rowan)
    game.addPersonToOtherTeam(dan)
    
    # End the game
    game.endGame(true, true)
  
    # Print out the document hash
    game.document.to_json
  
  end
=======
  
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
        # Create a Player Controller
        pc = PlayerController.new settings.couchdb
        leaderboard = pc.leaderboard
        leaderboard.to_s
    end
>>>>>>> Stashed changes

end
