require 'curses'

class String
	def printsize
		return self.each_char.map{ |c| c.bytesize==1 ? 1 : 2 }.reduce(0,&:+)
	end
end

class Pane
	
	def initialize(win,color)
		@color = color
		@lines = win.maxy-4
		@cols = win.maxx-2
		@window = win.subwin(win.maxy-2,win.maxx,0,0)
		@window.box(?|,?-,?+)
		@window.scrollok(true)
		@tweets=[]
	end

	def add(tweet)
		@tweets.push(tweet)
		if @tweets.length > @lines then
			@tweets.shift
		end
	end

	def print_size(string)
		string.each_char.map{ |c| c.bytesize == 1?1:2 }.reduce(0,&:+)
	end

	def show
		@tweets.each_with_index do |tweet,index|
			display_text = <<"EOS"
@#{tweet.user.screen_name}
    
#{tweet.text}
EOS
			display_text = display_text.gsub(/\n/,"")
			pos = display_text.length
			while display_text.is_a?(String) && display_text.printsize > @cols
				pos-=1
				display_text = display_text[0,pos]
			end
			@window.setpos(index+1,1)
			@window.addstr(" "*@cols)
			@window.setpos(index+1,1)
			@window.addstr(display_text)
		end
		@window.setpos(0,0)
		@window.refresh
	end
end
		
