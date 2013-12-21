require 'json'
require 'sinatra'
require 'time'

module Cinch
  module Plugins
    class GitListener

      include Cinch::Plugin
      def initialize(m)
        super(m)

        set :bind, '0.0.0.0'

        post '/commit/?' do
          data = JSON.parse(request.env["rack.input"].read)

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
      end
    end
  end
end
