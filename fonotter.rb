require 'curses'
require 'yaml'
require 'oauth'
require 'oauth/consumer'
require 'readline'

$settings = YAML::load_file('./settings.yml')
CONSUMER_KEY = settings['consumer_key']
CONSUMER_SECRET = settings['consumer_secret']
ACCESS_TOKEN = settings['access_token']
ACCESS_TOKEN_SECRET = settings['access_token_secret']

class Setup

	def self.request_token
		@request_token = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,{:site=>"https://api.twitter.com"}).get_request_token
		verifier = Readline.readline("Visit following url and Enter PIN Code...\n#{@request_token.authorize_url}\nPIN:").chomp;
		@access_token = @request_token.get_access_token(:oauth_verifier => verifier)
		unless @access_token.token || @access_token.secret then
			puts "Authentication Failed"
			self.request_token
		else
			puts "Authentication Success"
			settings['access_token'] = @access_token.token
			settings['access_token_secret'] = @access_token.secret
			File.open('./settings.yml','w'){|f| f.write settings.to_yaml}
		end
	end
		
end

Setup.request_token unless ACCESS_TOKEN || ACCESS_TOKEN_SECRET


