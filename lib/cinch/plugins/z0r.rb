module Cinch
  module Plugins
    class Z0r
      include Cinch::Plugin
      set :prefix, '!z0r '

      match /(\d+)(\s*\d{1,2})?/
      def execute(m, id, loops)
        loops = 1 if loops.to_i <= 0
        video = "http://raz.z0r.de/L/z0r-de_#{id}.swf "*loops.to_i
        cmd = "#{config[:player]} #{video}"
        pid = Process.spawn(cmd)
      end
    end
  end
end