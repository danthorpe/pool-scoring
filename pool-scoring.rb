require 'json/ext'
require 'sinatra/base'
require 'couchrest'

require './Models/Person.rb'

class PoolScoring < Sinatra::Base

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

end
