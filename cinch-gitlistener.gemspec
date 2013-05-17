Gem::Specification.new do |s|
  s.name        = 'cinch-gitlistener'
  s.version     = '0.0.1'
  s.date        = '2010-04-28'
  s.summary     = "Cinch Gitlistener"
  s.description = "Listens for post-receive git hooks"
  s.authors     = ["Adrian Leva"]
  s.email       = 'adrian.leva@gmail.com'
  s.files       = ["lib/cinch/plugins/gitlistener.rb"]
  s.add_dependency('cinchize')
  s.homepage    = ''
end