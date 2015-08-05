require 'curses'
require 'oauth'

CONSUMER_KEY=''
CONSUMER_SECRET=''

def Class Setup

	def self.request
		request_token =  OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,:site=>"https://twitter.com").get_request_token
		 p @request_token.authorized_uri
	end

	def self.verify(verifier)
		access_token = request_token.get_access_token(:oauth_verifier => verifier)
		return access_token.token,access_token.secret
	end
		
end
