# @author Daniel Thorpe dan@blindingskies.com
# @date 18/12/2011

# A module to group together CouchDB related functionality
module CouchDB

    # The database name
    DB = 'poolscoring'

    def CouchDB.nextUUID(server)
        # Get a new id from the CouchDB server
        uuids = CouchRest.get server + '/_uuids'
        return uuids["uuids"][0]
    end
  
end