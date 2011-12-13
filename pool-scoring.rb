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
  set :public_folder, 'public'
  set :static, true
  set :mustache, {
    :views => './Views',
    :templates => './Views/templates'
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
    mustache :index
  end
  
  # Style-guide page - temporary.
  get '/styleguide' do
    @title = 'Style-Guide'
    mustache :styleguide
  end

  # All players page.
  get '/players' do
    @title = 'Players'
    @players = self.players
    mustache :players
  end

  # Single player page.
  get '/player/:username' do
    @player = self.playerWithUsername params[:username]
    @title = @player.name
    mustache :player
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
