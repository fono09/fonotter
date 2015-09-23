require 'curses'

class String
	def printsize
		return self.each_char.map{ |c| c.bytesize==1 ? 1 : 2 }.reduce(0,&:+)
	end
end

class Column

	def initialize(win,width,height,top,left)
		@lines = width
		@cols = height
		@window = win.subwin(width,height,top,left)
		@contents=[]
	end

	def add(str)
		@contents.push(str)
		if @contents.length > @lines then
			@contents.shift
		end
	end
	
	def show
		@window.clear
		@contents.each_with_index do |content,index|
			display_str = content
			post = display_str.length
			while display_str.is_a?(String) && display_str.printsize > @cols
				post-=1
				display_text = display_text[0,pos]
			end
			@window.setpos(index,0)
			@window.addstr(display_text)
		end
		@window.refresh
	end
end

class Table

	def initialize(win,width,height,top,left,*cols_width)
		left_pos = 0
		@win = win
		@width = width
		@height = height
		@top = top
		@left = left
		@columns = []
		cols_width.each_with_index do |width,index|
			@columns.push(Column.new(win,width,height,top,left_pos))
			left_pos += width
		end
	end

	def add(strings)
		@columns.zip(strings) do |column,str|
			column.add(str)
		end
	end

	def show
		@columns.each do |column|
			column.show
		end
	end

end

class Pane
	
	def initialize(win,color)
		@color = color
		@lines = win.maxy
		@cols = win.maxx
		@window = win.subwin(win.maxy,win.maxx,0,0)
		@window.scrollok(true)
		@tweets=[]
		init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
	end

	def add(tweet)
		@tweets.push(tweet)
		if @tweets.length > @lines then
			@tweets.shift
		end
	end

	def show
		@window.clear
		@tweets.each_with_index do |tweet,index|

			display_text = <<"EOS"
@#{tweet.user.screen_name}
    
#{tweet.text}
EOS
			display_text = display_text.gsub(/\n/,"")
			pos = display_text.length
			while display_text.is_a?(String) && display_text.printsize > @cols+1
				pos-=1
				display_text = display_text[0,pos]
			end
			@window.setpos(index,0)
			@window.addstr(display_text)
		end
		@window.setpos(0,0)
		@window.refresh
	end
end
		
