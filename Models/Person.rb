# @author Daniel Thorpe dan@blindingskies.com
# @date 10/12/2011

# Person class
class Person  

  # Constructor
  # @param doc A CouchDB document representing the person
  def initialize(doc)
    @doc = doc
    
  end

  # Use define_method for accessing the underlying CouchDB attributes
  %w(_id name email username).each do | method |
    define_method(method) { @doc[method.to_s] }
  end
    
  def to_s
    "(#{self.username}, #{self.email})"
  end
  
  def to_json
    @doc.to_json
  end
end