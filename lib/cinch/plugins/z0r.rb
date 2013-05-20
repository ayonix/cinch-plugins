require 'open-uri'
require 'nokogiri'

module Cinch
  module Plugins
    class Z0r
      include Cinch::Plugin
      set :prefix, '!z0r '

      match /random (\d+)/, method: :random
      def random(m, seconds)
        max_id = get_max_id
        id = rand(0..max_id)
        play(m,id,seconds)
      end

      match /(\d+)(\s*\d{1,2})?/, method: :play
      def play(m, id, seconds)
        max_id = get_max_id
        seconds = 10 if seconds.to_i <= 0
        id = rand(0..max_id) if id.to_i > max_id 

        video = get_real_url(id)
        cmd = "#{config[:player]} #{video}"

        pid = Process.spawn(cmd)
        m.reply("Playing z0r.de/#{id} for #{seconds} seconds")
        sleep(seconds.to_i)
        Process.kill('TERM',pid)
      end

      def get_max_id
        page = Nokogiri::HTML(open('http://z0r.de/0'))
        id = page.search("[text()*='Previous']").first.attributes["href"].value.to_i
        return id
      end

      def get_real_url(id)
        url = "http://z0r.de/#{id}"
        page = Nokogiri::HTML(open(url))
        real_url = ''
        page.css('script').any? do |s|
          real_url = s.content.match(/swfobject.embedSWF\(\"(?<url>.*?)\"/)
        end
        return real_url[:url]
      end
    end
  end
end