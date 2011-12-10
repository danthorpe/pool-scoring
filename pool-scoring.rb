require 'json'
require 'couchrest'
require 'sinatra/base'

Class PoolScoring < Sinatra::Base

	# Define which CouchDB instance to use.
	if ENV['CLOUDANT_URL']
		set :db, ENV['CLOUDANT_URL'] + '/poolscoring'
	else
		set :db, 'http://localhost:5984/poolscoring'
	end


end