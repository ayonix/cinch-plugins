require 'open-uri'
require 'uri'
require 'nokogiri'

module Cinch
  module Plugins
    class Title
      include Cinch::Plugin

      set :prefix, /^[^!]/

      match /.*/
      def execute(m)
        puts m.message
        urls = URI.extract m.message
        titles = []
        urls.each do |url| 
          begin 
            titles << Nokogiri::HTML(open(url), nil, 'utf-8').css('title').text
          rescue Exception => e
          end
        end
        m.reply titles.join(' == ')
      end
    end
  end
end
