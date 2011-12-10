require 'sinatra/base'
require 'json/ext'
require 'couchrest'

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

  # Index page
  get '/' do
    "Hello World"
  end

end
