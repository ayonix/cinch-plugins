# coding: utf-8
require 'ruby-mpd'
require 'open-uri'

module Cinch
	module Plugins
		class Mpd
			include Cinch::Plugin
			set :prefix, '!mpd '

			def connect_mpd
				@mpd ||= MPD.new(config["address"],config["port"])
				@mpd.connect unless @mpd.connected?
			end

			match /play/, method: :play
			def play(m)
				connect_mpd
				@mpd.play
			end

			match /pause/, method: :pause
			def pause(m)
				connect_mpd
				@mpd.pause=true
			end

			match /volume\s*([0-9]*)/, method: :volume
			def volume(m, vol)
				connect_mpd
				if vol.nil?
					@mpd.volume = vol.to_i
				else
					m.reply "Volume: #{@mpd.volume}"
				end
			end

			match /mute/, method: :mute
			def mute(m)
				connect_mpd
				@mpd.volume = 0
			end

			match /next/, method: :next
			def next(m)
				connect_mpd
				@mpd.next
			end

			match /load (.+)/, method: :load
			def load(m, argument)
				connect_mpd

				case argument
				when /https?:\/\/.*\.m3u/
					@mpd.clear
					url = open(argument).read[/https?:\/\/.*/]
					@mpd.add url
					GC.start
					@mpd.play
					m.reply("Spiele #{url} ab.")
				when /https?:\/\/.*/
					@mpd.clear
					@mpd.add argument
					@mpd.play 
					m.reply("Spiele #{argument} ab.")
				else
					playlist = @mpd.playlists.select {|pl| pl.name == argument}.first
					if playlist.nil?
						m.reply("Konnte die Playlist #{argument} nicht finden.")	
					else
						@mpd.clear
						playlist.load
						m.reply("Playlist #{argument} wurde geladen.")
						@mpd.play
					end
				end
			end

			match /toggle/, method: :toggle
			def toggle(m)
				connect_mpd
				@mpd.pause=@mpd.playing?
			end

			match /list/, method: :list
			def list(m)
				connect_mpd
				playlists = @mpd.playlists.map{|pl| pl.name}.join(',')
				m.reply("Playlists: #{playlists}")
			end	

			match /status/, method: :status
			def status(m)
				connect_mpd
				status = @mpd.status
				current_song = @mpd.current_song
				if current_song.nil? 
					song_name = 'No Song'
				else
					song_name = "#{current_song.artist} - #{current_song.title}"
				end
				m.reply("Mpd Status: #{status[:state]}, Volume: #{status[:volume]}, Song: #{song_name}, in der Liste: #{status[:playlistlength]}")
			end

			match /import (.+)/, method: :import
			def import(m, argument)
				connect_mpd
				@mpd.add argument
				@mpd.play 
			end

			match /clear/, method: :clear
			def clear(m)
				connect_mpd
				@mpd.clear
			end

			match /save (.+)/, method: :save
			def save(m, argument)
				connect_mpd
				name = /(?<name>.*)(\.m3u)?/.match(argument)[:name]
				begin
					@mpd.save name
					m.reply("Saved playlist #{name}.")
				rescue MPD::AlreadyExists => e
					m.reply("Playlist '#{name}' already exists.")
				end
			end

			match /help/, method: :help
			def help(m)
				m.reply('Befehle: !mpd [play/pause/volume [<int>]/mute/next/load <uri|playlist>/toggle/list/status/import <uri_of_subfolder>/clear/save <name>].')
			end
		end
	end
end
