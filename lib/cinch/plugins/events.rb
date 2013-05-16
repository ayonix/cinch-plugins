require 'data_mapper'  

module Cinch
	module Plugins
		class Events
			include Cinch::Plugin
			set :prefix, '!event '

			DataMapper.setup(:default, 'postgres://cinch@localhost/cinch')

			match /add (.+)/, method: :add_all
			def add_all(m, text)
				e = Event.new what: text, when: parse_time(text), creator: m.user.nick
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
				event = find_event(text)
				if m.channel.opped?(m.user) or event.creator == m.user.nick
					event.destroy
					m.reply('Event wurde gelöscht.')
				else
					m.reply('Du musst Operator sein oder das Event erstellt haben.')
				end
			end

			match /dabei (.+)/, method: :attend, :prefix => '!'
			def attend(m, text)
				event = find_event(text)
				if event.nil?
					m.reply("Das Event kenne ich nicht.")
				else 
					event.attend(m.user.nick)
					m.reply("Du bist dabei!")
				end
			end

			match /nd (.+)/, method: :dont_attend, :prefix => '!'
			def dont_attend(m, text)
				event = find_event(text)
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
				events = Event.available
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

			def find_events(text)
				Event.available.all(:what.like => "%#{text}%")
			end

			def find_event(text)
				Event.available.first(:what.like => "%#{text}%")
			end

			def parse_time(text)
				formats = ['%d.%m.%Y', '(%d.%m.%Y)', '%d.%m.%Y)']
date_strings = text.scan /\d{2}.\d{2}.\d{4}/
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

				# DataMapper.setup(:default, "sqlite:///home/adrian/test.db")

				property :id, Serial
				property :when, DateTime
				property :what, String, required: true, :message => "Das Event braucht ein 'was'"
				property :who, String, :default => ""
				property :creator, String

				validates_uniqueness_of :what, :scope => :when, :message => "An dem Tag gibt es schon so ein Event"
				validates_with_method :when, :method => :check_date

				DataMapper.finalize
				DataMapper.auto_upgrade!

				def self.available
					Event.all(:when.gte => DateTime.now, :order => [:when.asc])
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
					return "#{self.what} in #{days} Tagen"
				end

				private 
				def check_date
					return [false,'Das Event braucht ein Datum dd.mm.yyyy [hh:mm]'] if self.when.nil?
					return self.when - DateTime.now > 0 ? true : [false,'Das Event war also schon?']
				end
			end

			# DataMapper.setup(:default, "sqlite::memory:")
		end
	end
end
