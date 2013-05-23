require 'open-uri'
require 'nokogiri'

module Cinch
	module Plugins
		class Title
			include Cinch::Plugin

			set :prefix, ''
			match /^(\b[^!].+\b)*(https?:\/\/[^\s]*)/, method: :getTitle

			def getTitle(m, prefix, url)
				page = Nokogiri::HTML(open(url), nil, 'utf-8')
				m.reply(page.css('title').text)
			end
		end
	end
end
