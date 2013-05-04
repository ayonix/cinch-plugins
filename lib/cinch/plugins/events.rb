require 'dm-core'  
require 'dm-timestamps'  
require 'dm-validations'  
require 'dm-migrations' 

module Cinch
	module Plugins
		class Events
			include Cinch::Plugin
			set :prefix, '!events '

			def initialize(m)
				DataMapper.setup :default, "sqlite://#{config["db"]}"
			end

			match /add (.+),(.+),(.+)/, method: :add
			def add(m, text, location, time)
				e = Event.new what: text, where: location, when: time
				if e.save
					m.reply(e saved)
				else
					m.reply("Something went wrong")
				end
			end

			match /list/, method: :list
			def list(m)
				m.reply(Event.all(:when.gte => DateTime.now))
			end

			class Event
				include DataMapper::Resource
				property :id, Serial
				property :where, String, required: true
				property :when, DateTime, required: true
				property :what, String, required: true
				property :who, String
				auto_upgrade!
			end
		end
	end
end
