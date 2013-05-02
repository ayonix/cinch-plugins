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
				super
				@mpd = MPD.new(config["address"],config["port"])
				@queue = Queue.new
			end

			def mpd_connect
				@mpd.connect unless @mpd.connected?
				@mpd.password config["password"] unless config["password"].nil?
			end

			match /(https?:\/\/www.youtube.com\/watch.*[^\s])/, method: :enqueue
			def enqueue(m, url)
				@queue << url
				playvideo m unless @playing
			end

			def playvideo(m)
				@playing = true
				url = @queue.pop
				@pid = Process.spawn("#{config["player"]} $(youtube-dl -g #{url})", :out => '/dev/null', :err => '/dev/null', :prgoup => true)
				mpd_connect
				@mpd.stop
				m.reply("Now playing on youtube: #{getTitle(url)}")

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
				page = Nokogiri::HTML(open(url))
				return page.css('title').text
			end
		end
	end
end
