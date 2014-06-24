require 'shellwords'

module Cinch
  module Plugins
    class Espeak
      include Cinch::Plugin

      match /speak (.*)$/
      def execute(m, text)
      	spawn("#{config[:command]} #{text.shellescape}")
      end
    end
  end
end
