require 'json'
require 'socket'

module Cinch
  module Plugins
    class GitListener

      include Cinch::Plugin
      def initialize(m)
        super(m)

        server = TCPServer.new config[:port]
        Thread.new do
          loop do
            Thread.start(server.accept) do |client|
              pw = client.gets.chomp
              client.close unless pw == config[:password]

              data = JSON.parse(client.gets)
              debug "Data #{data}"
              client.close
              data["payload"]["commits"].each do |commit|
                config[:channels].each do |ch| 
                  Channel(ch).send "[#{data["payload"]["repository"]["name"]}] #{commit["message"]} (#{commit["author"]["name"]}) am #{commit["timestamp"]}"
                end
              end
            end
          end
        end
      end

    end
  end
end
