require 'yaml'

module Cinch
	module Plugins
		class Admin
			include Cinch::Plugin

			def initialize(m)
				super
				@admins = YAML.load_file(config["file"])
				@admins ||= Hash.new
			end

			# aop users that join the channel
			listen_to :join, method: :op
			def op(m)
				if m.channel.opped? m.bot 
					m.channel.op m.user if not @admins[m.channel.name].nil? and @admins[m.channel.name].include? m.user.name
				else
					m.reply "I would have opped you #{m.user.nick} but I have no rights" unless m.user == m.bot
				end
			end

			# join channels if the bot is invited
			listen_to :invite, method: :follow_invite
			def follow_invite(m)
				m.bot.join m.channel
			end

			match /admins/, method: :list
			def list(m)
				m.reply("Admins: #{@admins[m.channel.name]}")
			end

			match /invite (.+)/, method: :invite
			def invite(m, channel)
				if m.bot.channels.include? channel
					ch = m.bot.channels.find{|c| c.name == channel}
					debug ch.inspect
					unless ch.nil?
						ch.invite m.user 
					end
				end
			end

			match /aop (.+[^\s])/, method: :add_admin
			def add_admin(m, nick)
				if m.channel.opped? m.user
					if @admins[m.channel.name].nil?
						@admins[m.channel.name] = [nick]
					else
						@admins[m.channel.name] << nick unless @admins[m.channel.name].include? nick
					end
					save
					m.reply "#{nick} added to aop list for #{m.channel.name}"
				else
					m.reply "You have to be operator to do so"
				end
			end

			match /deop (.+[^\s])/, method: :del_admin
			def del_admin(m, nick)
				if m.channel.opped? m.user
					if @admins[m.channel.name].include? nick
						@admins[m.channel.name].delete nick
						save
						m.reply "#{nick} has been removed from aop list for #{m.channel.name}"
					else
						m.reply "#{nick} was not found on aop list for #{m.channel.name}"
					end
				else
					m.reply "You have to be operator to do so"
				end
			end

			def save
				File.open(config["file"], "w") { |file| file.write(YAML.dump(@admins)) }
			end
		end
	end
end