# This plugin requires youtube-dl to be in your path
require 'thread'
require 'nokogiri'
require 'open-uri'

module Cinch
	module Plugins
		class Youtube
			include Cinch::Plugin

			set :prefix, /!yt /
			match /(https?:\/\/www.youtube.com\/watch.*[^\s])/, method: :enqueue
			match 'clear', method: :clear
			match 'skip', method: :skip

			def initialize(m)
				super
				@mpd = Mpd.new(config["address"],config["port"])
				@queue = Queue.new
			end

			def enqueue(m, url)
				@queue << url
				playvideo m unless @playing
			end

			def playvideo(m)
				@playing = true
				# @pid = Process.spawn("#{settings['player']} $(youtube-dl -g #{@queue.pop})", :pgroup=>true)
				url = @queue.pop
				@pid = Process.spawn("#{config["player"]} $(youtube-dl -g #{url})", :out => '/dev/null', :err => '/dev/null')
				@mpd.connect unless @mpd.connected?
				@mpd.stop
				m.reply("Now playing on youtube: #{getTitle(url)}")

				# thread to wait for the process to exit
				# play next video in queue or resume mpd
				Process.wait(@pid)
				@playing = false
				if @queue.empty?
					@pid = nil
					GC.start
					@mpd.connect unless @mpd.connected?
					@mpd.play
				else
					playvideo m
				end
			end

			def skip(m)
				unless @pid.nil? 
					# Process.kill("TERM", -Process.getpgid(@pid))
					Process.kill("TERM", @pid)
				end
			end

			def clear(m)
				m.reply("Youtube playlist cleared")
				@queue.clear unless @queue.nil?
				skip(m)
			end

			def getTitle(url)
				page = Nokogiri::HTML(open(url))
				return page.css('title').text
			end
		end
	end
end
