require 'curses'
require 'unicode_utils'

def init_color 
	color_list = [
		COLOR_BLACK,
		COLOR_WHITE,
		COLOR_BLUE,
		COLOR_CYAN,
		COLOR_GREEN,
		COLOR_MAGENTA,
		COLOR_RED,
		COLOR_YELLOW
	]

	cnt = 0
	color_list.each.with_index {|fg,i|

		(0..i-1).each do |j|
			bg = color_list[j]
			init_pair(cnt,fg,bg)
			cnt+=1
		end

		(i+1..color_list.length-1).each do |j|
			bg = color_list[j]
			init_pair(cnt,fg,bg)
			cnt+=1
		end

	}
end

init_color

class DisplayString 

	def initialize(str,color_id)
		@str = str
		@color_id = color_id
	end

	def display_width
		UnicodeUtils.display_width(@str)
	end

	def print(win,x,y)
		win.setpos(x,y)
		win.attron(color_pair(@color_id))
		win.addstr(@str)
		win.attroff(color_pair(@color_id))
	end
		
end

class String

	def printsize
		UnicodeUtils.display_width(self)
	end

end

class Column

	def initialize(win,width,height,top,left)
		@width = width
		@height = height
		@top = top
		@left = left
		@window = win.subwin(@height,@width,@top,@left)
		@columns=[]
	end

	def add(str)
		@columns.push(str)
		if @columns.length > @height then
			@columns.shift
		end
	end

	def show
		@columns.each_with_index do |content,index|
			if content.is_a?(String) then
				display_str = content
				display_str = display_str.gsub(/(\r\n|\r|\n)/,'')
				pos = display_str.length
				while display_str.printsize > @width
					pos-=1
					display_str = display_str[0,pos]
				end
				@window.setpos(index,0)
				@window.addstr(display_str)
			elsif content.is_a?(Array) then
				pos_col = 0
				content.each do |str|
				end
			end

		end
	end
end

class Table

	def initialize(win,width,height,top,left,cols_width)
		left_pos = 0
		@window = win
		@width = width
		@height = height
		@top = top
		@left = left
		@columns = []
		@columns_width = cols_width
		@columns_width.each_with_index do |width,index|
			@columns.push(Column.new(@window,width,@height,@top,left_pos))
			left_pos += width
		end
	end

	def add(strings)
		@columns.zip(strings) do |column,str|
			column.add(str)
		end
	end

	def show
		@window.clear
		@columns.each do |column|
			column.show
		end
		@window.refresh
	end

end
