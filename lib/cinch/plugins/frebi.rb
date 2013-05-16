require 'nokogiri'
require 'open-uri'

module Cinch
	module Plugins
		class Frebi
			include Cinch::Plugin
			set :prefix, /!frebi /
			@@frebi_sounds = {}

			page = Nokogiri::HTML(open('http://sounds.frebi.org'))
			# get name, url and trigger
			page.css('button').each do |button|
				name = /playSound\('(?<name>.*)'\)/.match(button.attributes['onclick'].value)[:name]
				text = button.children.to_s
				url = page.css('audio').select{|a| a.attributes['id'].value == name}.first.attributes['src'].value
				url = "http://sounds.frebi.org/#{url}"
				@@frebi_sounds[text.downcase] = url
				match Regexp.new("(#{text})",true), use_prefix: false
			end

			def execute(m, text)
				`#{config[:player]} #{@@frebi_sounds[text.downcase]}`
			end

			match /help/, method: :help
			def help(m)
				m.reply(@@frebi_sounds.keys.join("; "))
			end
		end
	end
end