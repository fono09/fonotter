require 'curses'

require 'yaml'
require 'oauth'
require 'oauth/consumer'
require 'readline'
require 'twitter'

require "./view"

$settings = YAML::load_file('./settings.yml')
CONSUMER_KEY = $settings['oauth_data']['consumer_key']
CONSUMER_SECRET = $settings['oauth_data']['consumer_secret']
ACCESS_TOKEN = $settings['oauth_data']['access_token']
ACCESS_TOKEN_SECRET = $settings['oauth_data']['access_token_secret']

DISPLAY_COLOR = $settings['display_color']


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
			$settings['oauth_data']['access_token'] = @access_token.token
			$settings['oauth_data']['access_token_secret'] = @access_token.secret
			File.open('./settings.yml','w'){|f| f.write $settings.to_yaml}
			puts "Restart me!"
			exit
		end
	end
		
end

Setup.request_token unless ACCESS_TOKEN || ACCESS_TOKEN_SECRET

main_view = View.new
width = main_view.width
height = main_view.height
table = Table.new(main_view.window,width,height/4*3,0,0,[width/5,width/5*4])

streaming_client = Twitter::Streaming::Client.new($settings['oauth_data'])
streaming_client.user do |obj|
	if obj.is_a?(Twitter::Tweet)
		text_column=[]

		if obj.text =~ /RT/ then 
			tmp = obj.text.split(/RT/)
			tmp.each.with_index do |str,i|
			
				unless tmp[i+1] != nil then
					text_column.push(DisplayString.new('RT',4))
				end

				unless str=="" then	
					text_column.push(DisplayString.new(str,0))
				end
				
			end
		else
			text_column.push(DisplayString.new(obj.text,0))
		end

		user_column=[DisplayString.new('@'+obj.user.screen_name,0)]
		table.add([user_column,text_column])
		table.show
	end
end
