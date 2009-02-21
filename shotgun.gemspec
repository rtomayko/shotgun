Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'shotgun'
  s.version = '0.1'
  s.date = '2009-02-20'

  s.description = "Because reloading sucks."
  s.summary     = s.description

  s.authors = ["Ryan Tomayko"]
  s.email = "r@tomayko.com"

  s.files = %w[
    README
    Rakefile
    shotgun.gemspec
    lib/shotgun.rb
    bin/shotgun
  ]
  s.executables = ['shotgun']
  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.extra_rdoc_files = %w[README]
  s.add_dependency 'rack', '>= 0.9.1', '< 1.0'

  s.homepage = "http://github.com/rtomayko/shotgun/"
  s.require_paths = %w[lib]
  s.rubyforge_project = 'wink'
  s.rubygems_version = '1.1.1'
end
