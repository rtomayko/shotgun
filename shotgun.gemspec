Gem::Specification.new do |s|
  s.name = 'shotgun'
  s.version = '0.9'
  s.date = '2011-02-24'

  s.description = "reloading rack development server"
  s.summary     = s.description

  s.authors = ["Ryan Tomayko"]
  s.email = "rtomayko@gmail.com"

  s.files = %w[
    COPYING
    README
    Rakefile
    bin/shotgun
    lib/shotgun.rb
    lib/shotgun/favicon.rb
    lib/shotgun/loader.rb
    lib/shotgun/static.rb
    man/index.txt
    man/shotgun.1
    man/shotgun.1.ronn
    shotgun.gemspec
    test/big.ru
    test/boom.ru
    test/slow.ru
    test/test-sinatra.ru
    test/test.ru
    test/test_shotgun_loader.rb
    test/test_shotgun_static.rb
  ]
  s.executables = ['shotgun']
  s.test_files = s.files.select { |f| f =~ /test_shotgun.*rb/ }

  s.extra_rdoc_files = %w[README]
  s.add_dependency 'rack',    '>= 1.0'

  s.homepage = "http://github.com/rtomayko/shotgun"
  s.require_paths = %w[lib]
end
