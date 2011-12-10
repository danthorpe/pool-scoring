# @author Daniel Thorpe dan@blindingskies.com
# @date 10/12/2011

# Person class
class Person  

  # Constructor
  # @param doc A CouchDB document representing the person
  def initialize(doc)
    @doc = doc
  end
  
  def name; @doc['name']; end
  def username; @doc['username']; end
  def email; @doc['email']; end
  
  def to_s
    "(#{@doc['username']}, #{@doc['email']})"
  end
  
  def to_json
    @doc.to_json
  end
end