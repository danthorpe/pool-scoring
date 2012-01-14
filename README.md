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
 * CouchDB

### Setup ###

Clone this repository onto your local machine.

From the root of the application, run the following to install all gem dependencies:

    $ bundle install

To set up CouchDB, you need a database and a user named `poolscoring`. The user's
password should be `yourmum`. Replicate the live database (ask Dan for help).

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

