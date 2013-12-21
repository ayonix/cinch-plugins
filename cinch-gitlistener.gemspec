Gem::Specification.new do |s|
  s.name        = 'cinch-gitlistener'
  s.version     = '0.0.5'
  s.date        = '2013-12-21'
  s.summary     = "Cinch Gitlistener"
  s.description = "Listens for post-receive git hooks"
  s.authors     = ["Adrian Leva"]
  s.email       = 'adrian.leva@gmail.com'
  s.files       = ["lib/cinch/plugins/gitlistener.rb"]
  s.add_dependency('cinchize')
  s.add_dependency('webrick')
  s.homepage    = ''
end
