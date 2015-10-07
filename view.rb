require 'curses'
include Curses

require 'unicode_utils'


class DisplayString 

	attr_accessor :str, :color_id

	def initialize(str,color_id)
		@str = str
		@color_id = color_id
	end

end

class String

	def display_width
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

			cursor_position = 0
			break_flag = false
			content.each do |display_string|

				str_pos = display_string.str.length
				temp = display_string.str.gsub(/(\r|\n)/,'')

				while cursor_position + temp.display_width > @width && str_pos > 1
					str_pos-=1
					temp = temp[0,str_pos]
				end
				

				unless str_pos == 0
					@window.setpos(index,cursor_position)
					@window.attron(color_pair(display_string.color_id))
					@window.addstr(temp)
					@window.attroff(color_pair(display_string.color_id))
				else
					break_flag = true	
					break
				end

				cursor_position += temp.display_width
			end
			
			break if break_flag == true 
		end
		#@window.refresh

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

class View 
	attr_reader :window, :width, :height

	def initialize 
		Curses.init_screen
		Curses.start_color
		init_color
		Curses.noecho
		@window = Curses.stdscr
		@width = @window.maxx
		@height = @window.maxy
		color_test
	end
	
	def color_test

		@window.clear
		cnt = Curses.color_pairs
		cnt.times do |c| 
			@window.setpos(c/10,c%10*10)
			@window.attron(color_pair(c))
			@window.addstr("id:#{c}")
			@window.attroff(color_pair(c))
		end
	
		@window.refresh

		sleep 10 
		
	end

	def init_color 
		color_list = [
			Curses::COLOR_BLACK,
			Curses::COLOR_WHITE,
			Curses::COLOR_BLUE,
			Curses::COLOR_CYAN,
			Curses::COLOR_GREEN,
			Curses::COLOR_MAGENTA,
			Curses::COLOR_RED,
			Curses::COLOR_YELLOW
		]

		cnt = 0
		color_list.each do |fg|

			color_list.each do |bg|
				init_pair(cnt,fg,bg)
				cnt+=1
			end

		end
		@colors = cnt

	end
end

