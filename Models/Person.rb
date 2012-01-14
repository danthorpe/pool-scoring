# @author Daniel Thorpe dan@blindingskies.com
# @date 10/12/2011

# Dependencies
require './Library/Gravatar.rb'

# Person class
class Person

<<<<<<< Updated upstream
  # Constructor
  # @param doc A CouchDB document representing the person
  # @param server A CouchDB server on which the document exists
  def initialize(doc=nil, server=nil)
    @doc = doc if doc != nil
    @server = server if server != nil
    @avatar = Gravatar.new doc['email'], 80, 'unicorn'
  end

  # Use define_method for accessing the underlying CouchDB attributes
  %w(_id name email username).each do | method |
    define_method(method) { @doc[method.to_s] }
  end
  
  def avatar
    @avatar
  end

  def to_s
    "(#{self.username}, #{self.email})"
  end

  def to_json
    @doc.to_json
  end
=======
    # Constructor
    # @param doc A CouchDB document representing the person
    # @param server A CouchDB server on which the document exists
    def initialize(doc=nil, server=nil)
        @doc = doc if doc != nil
        @server = server if server != nil
        @avatar = Gravatar.new doc['email'], 80, 'unicorn'
    end
    
    # Use define_method for accessing the underlying CouchDB attributes
    %w(_id name email username).each do | method |
        define_method(method) { @doc[method.to_s] }
    end
    
    def avatar
        @avatar
    end
    
    def to_s
        "(#{self.username}, #{self.email})"
    end
    
    def to_json
        @doc.to_json
    end
>>>>>>> Stashed changes
end