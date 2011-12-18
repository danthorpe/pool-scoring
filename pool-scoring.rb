require 'json/ext'
require 'sinatra/base'
require 'couchrest'
require 'mustache/sinatra'

# Load models
require './Models/Person.rb'
require './Models/Game.rb'

# Load controllers
require './Controllers/PlayerController.rb'

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
    pc = PlayerController.new settings.db
    @players = pc.all
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
    pc = PlayerController.new settings.db
    @player = pc.playerWithUsername params[:username]
    @title = @player.name
    mustache :'players/profile'
  end

  # Record a game
  get '/games/new' do
    @title = 'Record a Game'
    pc = PlayerController.new settings.db
    @players = pc.all
    mustache :'games/new'
  end
  
  post '/games/new' do
    'Boom! ' + params.to_s
  end

end
