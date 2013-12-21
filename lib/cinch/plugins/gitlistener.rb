require 'webrick'
require 'json'
require 'time'

module Cinch
  module Plugins
    class GitListener 
      include Cinch::Plugin

      def initialize(m)
        super(m)

        server = WEBrick::HTTPServer.new :Port => config[:port]

        server.mount_proc config[:path] do |req, res|
          data = JSON.parse(req.body)

          repo = data['repository']['name']
          branch = data['ref'].split('/').last
          user = data['user_name']
          commit_count = data['total_commits_count']

          config[:channels].each do |ch| 
            Channel(ch).send("#{user} pushed #{commit_count} commits to #{repo}/#{branch}:")

            data['commits'].each do |commit|
              message = commit['message']
              time = DateTime.strptime(commit['timestamp']).strftime("%a %d.%m. | %H:%M:%S")

              Channel(ch).send("[#{time}] #{message}")
            end
          end
        end

        trap 'INT' do 
          server.shutdown 
        end

        Thread.new do
          server.start
        end
      end
    end
  end
end