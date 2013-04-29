require 'open-uri'
require 'nokogiri'

module Cinch
	module Plugins
		class Title
			include Cinch::Plugin

			set :prefix, /.*/
			match /(https?:\/\/.*)/, method: :getTitle

			def getTitle(m, url)
				page = Nokogiri::HTML(open(url))
				m.reply(page.css('title').text)
			end
		end
	end
end