require 'thread'

module Cinch
  module Plugins
    class Espeak
      include Cinch::Plugin

      match /speak (.*)/
      def execute(m, text)
	spawn("espeak #{text}")
      end
    end
  end
end
