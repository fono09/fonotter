require 'curses'
include Curses

require 'yaml'
require 'oauth'
require 'oauth/consumer'
require 'readline'

$settings = YAML::load_file('./settings.yml')
CONSUMER_KEY = $settings['consumer_key']
CONSUMER_SECRET = $settings['consumer_secret']
ACCESS_TOKEN = $settings['access_token']
ACCESS_TOKEN_SECRET = $settings['access_token_secret']

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
			$settings['access_token'] = @access_token.token
			$settings['access_token_secret'] = @access_token.secret
			File.open('./settings.yml','w'){|f| f.write $settings.to_yaml}
			puts "Restart me!"
			exit
		end
	end
		
end

Setup.request_token unless ACCESS_TOKEN || ACCESS_TOKEN_SECRET

init_screen
cbreak
begin
	win = stdscr.subwin(stdscr.maxy,stdscr.maxx,0,0)
	win.box(?|,?-,?+)
	win.setpos(2,2)
	win.addstr(`tput cols`.chomp+","+`tput lines`.chomp)
	win.refresh
	getch
ensure
	close_screen
end

