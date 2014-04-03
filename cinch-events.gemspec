Gem::Specification.new do |s|
  s.name        = 'cinch-events'
  s.version     = '0.0.4'
  s.date        = '2014-04-03'
  s.summary     = "Cinch events"
  s.description = "Eventstuff"
  s.authors     = ["Adrian Leva"]
  s.email       = 'adrian.leva@gmail.com'
  s.files       = ["lib/cinch/plugins/events.rb"]
  s.add_dependency('cinchize')
  s.add_dependency('sqlite3')
  s.add_dependency('dm-core')
  s.add_dependency('dm-timestamps')
  s.add_dependency('dm-validations')
  s.add_dependency('dm-migrations')
  s.add_dependency('dm-sqlite-adapter')
  s.homepage    = ''
end
