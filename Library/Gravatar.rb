# @author Rowan Manning info@rowanmanning.co.uk
# @date 17/12/2011

# Dependencies
require 'digest/md5'

# Gravatar class. Used to represent a Gravatar
# avatar image.
class Gravatar

  # Class constructor.
  # @param email The email address to return an avatar for.
  # @param size The size of the avatar.
  # @param email The default image to use, should an avatar not be found.
  def initialize(email, size = 100, default = nil)
    @email = email
    @size = size
    @default = default
  end

  def emailHash
    Digest::MD5.hexdigest @email.downcase
  end
  
  def default
    case @default
      when 'unicorn'
        "http://unicornify.appspot.com/avatar/#{ self.emailHash }?s=#{ @size }"
      when 'kitten'
        "http://placekitten.com/#{ @size }/#{ @size }"
      else
        @default
    end
  end

  def url
    "http://www.gravatar.com/avatar/#{ self.emailHash }.jpg?s=#{ @size }&d=#{ default }"
  end

  def to_s
    url
  end

end