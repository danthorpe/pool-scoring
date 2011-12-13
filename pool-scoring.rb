require 'json/ext'
require 'sinatra/base'
require 'couchrest'
require 'mustache/sinatra'

# Load models
require './Models/Person.rb'
require './Models/Game.rb'

class PoolScoring < Sinatra::Base
  
  # Register mustache and initialise the Views module - Mustache requires this
  register Mustache::Sinatra
  module Views end
  
  # Define which CouchDB instance to use.
  if ENV['CLOUDANT_URL']
    set :db, ENV['CLOUDANT_URL'] + '/poolscoring'
  else
    set :db, 'http://localhost:5984/poolscoring'
  end

  set :root, File.dirname(__FILE__)
  set :public_folder, './Public'
  set :static, true
  set :mustache, {
    :views => './Views',
    :templates => './Templates'
  }

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
    result = CouchRest.get settings.db + '/_design/Person/_view/byUsername?key=%22' + username + '%22'
    return Person.new result['rows'][0]['value']
  end

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
    @players = self.players
    mustache :'players/index'
  end
  
  # Create players page.
  get '/players/new' do
    @title = 'Create a Player'
    mustache :'players/new'
  end
  post '/players/new' do
    'Boom! ' + params.to_s
  end

  # Single player profile.
  get '/player/:username' do
    @player = self.playerWithUsername params[:username]
    @title = @player.name
    mustache :'players/profile'
  end

  # Record a game (temporary URL - didn't want to step on the '/new' route)
  get '/games/new' do
    @title = 'Record a Game'
    @players = self.players
    mustache :'games/new'
  end
  post '/games/new' do
    'Boom! ' + params.to_s
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

end
