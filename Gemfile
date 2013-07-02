source 'https://rubygems.org'

# Specify your gem's dependencies in mongoid_multiparams.gemspec
gemspec

group :test do
  gem 'rake'
  gem 'mongoid', '~> 4.0.0', github: 'mongoid/mongoid'
  gem 'rspec', '~> 2.13.0'
  
  if ENV['CI']
    gem "coveralls", require: false
  end
end
