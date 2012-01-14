Pool Scoring
============

This is a very simple web app used to keep track of pool scores within an organization.


Running Locally
---------------

### Requirements ###

To run the app locally, you need the following:

 * Ruby (ideally 1.9.2)
 * Bundler. Install with `gem install bundler`
 * Shotgun. Install with `gem install shotgun`
 * CouchDB. Install with `brew install couchdb`
 * CouchApp. Install using [Installing CouchApp](http://couchapp.org/page/installing)

### Setup ###

Clone this repository onto your local machine.

From the root of the application, run the following to install all gem dependencies:

    $ bundle install

To set up CouchDB, you need a database and a user named `poolscoring`. The user's
password should be `yourmum`. To create the design documents, change into the 
`CouchApp` directory, and perform the following commands:

    $ couchapp push Game http://poolscoring:yourmum@localhost:5984/poolscoring
    $ couchapp push Person http://poolscoring:yourmum@localhost:5984/poolscoring

Double check that the design documents are present from within [Futon](http://localhost:5984/_utils/database.html?poolscoring/_design_docs).

### Running ###

Start the app by running the following from the root of the application:

    $ shotgun -p4567 config.ru

You can access your local clone now at http://localhost:4567/. Enjoy!


Documentation
-------------

Generate documentation by running:

    $ yarddoc

which may require you to install [YARD](http://yardoc.org/guides/index.html): 

    $ gem install yard
    $ gem install redcarpet

