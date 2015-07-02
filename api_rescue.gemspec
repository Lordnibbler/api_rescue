$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'api_rescue/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api_rescue'
  s.version     = ApiRescue::VERSION
  s.authors     = ['Ben Radler']
  s.email       = ['benradler@me.com']
  s.homepage    = 'http://github.com/lordnibbler/api_rescue'
  s.summary     = 'Awesome DRY API library'
  s.description = ''
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'jbuilder'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails', '~> 3.3'
end
