require 'json'

# Person class
class Person  

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