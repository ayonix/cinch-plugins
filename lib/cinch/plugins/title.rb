require 'open-uri'
require 'nokogiri'

module Cinch
	module Plugins
		class Title
			include Cinch::Plugin

			set :prefix, ''
			match /^(\b[^!].+\b)*(https?:\/\/[^\s]*)/, method: :getTitle

			def getTitle(m, prefix, url)
				begin
					page = Nokogiri::HTML(open(url), nil, 'utf-8')
					m.reply(page.css('title').text)
				rescue Exception => e
					m.reply("404")
				end
			end
		end
	end
end
