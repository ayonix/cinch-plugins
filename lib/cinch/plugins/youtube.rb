# This plugin requires youtube-dl to be in your path
require 'thread'
require 'nokogiri'
require 'open-uri'

module Cinch
	module Plugins
		class Youtube
			include Cinch::Plugin

			set :prefix, /!yt /

			def initialize(m)
				super(m)
				@mpd = MPD.new(config[:address],config[:port])
				@queue = Queue.new
			end

			def mpd_connect
				@mpd.connect unless @mpd.connected?
				@mpd.password config[:password] unless config[:password].nil? or config[:password].empty?
			end

			match /(https?:\/\/[^\s]*|gvsearch:.*|ytsearch:.*)/, method: :enqueue
			def enqueue(m, url)
				@queue << url 
				playvideo m unless @playing
			end

			def playvideo(m)
				@playing = true
				url = @queue.pop
				debug "#{config[:player]} $(youtube-dl -g '#{url}')"
				@pid = Process.spawn("#{config[:player]} $(youtube-dl -g '#{url}')", :out => '/dev/null', :err => '/dev/null', :pgroup => true)
				mpd_connect
				@mpd.stop
				m.reply("Now playing: #{getTitle(url)}")

				# thread to wait for the process to exit
				# play next video in queue or resume mpd
				Process.wait(@pid)
				@playing = false
				if @queue.empty?
					@pid = nil
					GC.start
					mpd_connect
					@mpd.play
				else
					playvideo m
				end
			end

			match 'skip', method: :skip
			def skip(m)
				Process.kill("TERM", -Process.getpgid(@pid)) unless @pid.nil?
			end

			match 'clear', method: :clear
			def clear(m)
				m.reply("Youtube playlist cleared")
				@queue.clear unless @queue.nil?
				skip(m)
			end

			def getTitle(url)
				begin
					page = Nokogiri::HTML(open(url), nil, 'utf-8')
					return page.css('title').text
				rescue Exception => e
					url	
				end
			end
		end
	end
end
