# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','agmcat','version.rb'])

spec = Gem::Specification.new do |s|
  s.name          = 'agmcat'
  s.version       = Agmcat::VERSION
  s.author        = 'Daniel Perez'
  s.email         = 'dpmex4527@gmail.com'
  s.summary       = %q{Migrate HPE Agile Manager user stories to GitHub Issues.}
  s.description   = %q{A simple utility for migrating HPE Agile Manager user stories of a given release into GitHub issues at a specified repository.}
  s.homepage      = 'https://github.com/dpmex4527'
  s.license       = "MIT"
  s.platform      = Gem::Platform::RUBY

  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','agmcat.rdoc']
  s.rdoc_options << '--title' << 'agmcat' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'agmcat'
  s.add_development_dependency "bundler", "~> 1.14"
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.15.0')
  s.add_runtime_dependency('rest-client')
  s.add_runtime_dependency('terminal-table')
  s.add_runtime_dependency('reverse_markdown')
end
