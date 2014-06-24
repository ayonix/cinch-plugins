require 'nokogiri'
require 'open-uri'

module Cinch
	module Plugins
		class Youtube
			include Cinch::Plugin

			set :prefix, /!yt /
			match 'skip', method: :skip, group: :yt
			match 'clear', method: :clear, group: :yt
			match /(.+)/, method: :enqueue, group: :yt

			def initialize(m)
				super(m)
				@queue = Queue.new
			end

			def enqueue(m, text)
				urls = URI.extract text
				urls.each { |url| @queue << url }
				playvideo m unless @playing
			end

			def playvideo(m)
				@playing = true
				url = @queue.pop
				@pid = Process.spawn("#{config[:player]} #{url}", :pgroup => true)
				m.reply("Now playing: #{getTitle(url)}")

				# thread to wait for the process to exit
				# play next video in queue
				Process.wait(@pid)
				@playing = false
				if @queue.empty?
					@pid = nil
					GC.start
				else
					playvideo m
				end
			end

			def skip(m)
				Process.kill("TERM", -Process.getpgid(@pid)) unless @pid.nil?
			end

			def clear(m)
				m.reply("Youtube playlist cleared")
				@queue.clear unless @queue.nil?
				skip(m)
			end

			def getTitle(url)
				begin
					page = Nokogiri::HTML(open(url), nil, 'utf-8')
					return page.title.gsub(/(\r\n?|\n|\t)/, "")
				rescue Exception => e
					"Something..."
				end
			end
		end
	end
end
