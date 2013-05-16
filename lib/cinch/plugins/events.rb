require 'data_mapper'  

module Cinch
	module Plugins
		class Events
			include Cinch::Plugin
			set :prefix, '!event '

			def initialize(m)
				super(m)
				DataMapper.setup(:default, "sqlite://#{config[:db_path]}")
				DataMapper.finalize
				DataMapper.auto_upgrade!
			end

			match /add (.+)/, method: :add_all
			def add_all(m, text)
				e = Event.new what: text, when: parse_time(text), creator: m.user.nick, channel: m.channel.name
				if e.save
					m.reply("Läuft.")
				else
					e.errors.each do |error|
						m.reply(error.first)
					end
				end
			end

			match /del (.+)/, method: :delete
			def delete(m, text)
				event = find_event(text, m.channel.name)
				if m.channel.opped?(m.user) or event.creator == m.user.nick
					event.destroy
					m.reply('Event wurde gelöscht.')
				else
					m.reply('Du musst Operator sein oder das Event erstellt haben.')
				end
			end

			match /db (.+)/, method: :attend, :prefix => '!'
			match /dabei (.+)/, method: :attend, :prefix => '!'
			def attend(m, text)
				event = find_event(text, m.channel.name)
				if event.nil?
					m.reply("Das Event kenne ich nicht.")
				else 
					event.attend(m.user.nick)
					m.reply("Du bist dabei!")
				end
			end

			match /nd (.+)/, method: :dont_attend, :prefix => '!'
			def dont_attend(m, text)
				event = find_event(text, m.channel.name)
				if event.nil?
					m.reply("Das Event kenne ich nicht.")	
				else
					event.dont_attend(m.user.nick)
					m.reply("Du bist nicht dabei.")
				end
			end

			match /list/, method: :list
			match /events/, method: :list, :prefix => '!'
			def list(m)
				events = Event.available(m.channel.name)
				if events.size > 0	
					i = 1
					events.each do |event|
						m.reply("#{i}: #{event}")
						i+=1
						m.reply("Dabei: #{event.who}") unless event.who.empty?
					end
				else
					m.reply("Keine Events vorhanden")
				end
			end

			def find_events(text, channel)
				Event.available(channel).all(:what.like => "%#{text}%")
			end

			def find_event(text, channel)
				Event.available(channel).first(:what.like => "%#{text}%")
			end

			def parse_time(text)
				formats = ['%d.%m.%Y', '(%d.%m.%Y)', '%d.%m.%Y)']
				date_strings = text.scan /\d{1,2}.\d{1,2}.\d{4}/
				date = nil
				date_strings.any? do |s|
					formats.any? do |format|
						date = DateTime.strptime(s,format) rescue nil
					end
				end
				return date
			end

			class Event
				include DataMapper::Resource
				property :id, Serial
				property :when, DateTime
				property :what, String, required: true, :message => "Das Event braucht ein 'was'"
				property :who, String, :default => ""
				property :creator, String
				property :channel, String

				validates_uniqueness_of :what, :scope => [:when,:channel], :message => "An dem Tag gibt es schon so ein Event"
				validates_with_method :when, :method => :check_date

				def self.available(channel)
					Event.all(:when.gte => DateTime.now, :order => [:when.asc], :channel => channel)
				end

				def attend(nick)
					nicks = self.who.split(" ")
					nicks << nick unless nicks.include? nick
					self.who = nicks.join(" ")
					self.save
				end

				def dont_attend(nick)
					nicks = self.who.split(" ")
					nicks.delete(nick) if nicks.include? nick
					self.who = nicks.join(" ")
					self.save
				end

				def to_s
					days = (self.when - Date.today).to_i
					return "#{self.what} #{days_helper(days)}"
				end

				def days_helper(days)
					case days
						when 1
							"morgen"
						when 2
							"übermorgen"
						else
							"in #{days} Tagen"
						end
				end

				private 
				def check_date
					return [false,'Das Event braucht ein Datum dd.mm.yyyy [hh:mm]'] if self.when.nil?
					return self.when - DateTime.now > 0 ? true : [false,'Das Event war also schon?']
				end
			end
		end
	end
end
