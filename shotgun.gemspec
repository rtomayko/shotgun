Gem::Specification.new do |s|
  s.name = 'shotgun'
  s.version = '0.9.2'

  s.description = "Reloading Rack development server"
  s.summary     = s.description

  s.license = "MIT"

  s.authors = ["Ryan Tomayko"]
  s.email = "rtomayko@gmail.com"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency 'rack',    '>= 1.0'

  s.homepage = "https://github.com/rtomayko/shotgun"
end
