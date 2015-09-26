require 'curses'

class String
	def printsize
		return self.each_char.map{ |c| c.bytesize==1 ? 1 : 2 }.reduce(0,&:+)
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
			display_str = content
			display_str = display_str.gsub(/(\r\n|\r|\n)/,'')
			pos = display_str.length
			while display_str.printsize > @width
				pos-=1
				display_str = display_str[0,pos]
			end
			@window.setpos(index,0)
			@window.addstr(display_str)
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
		p [@width,@height,@top,@left]
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
