#
# Copyright (c) 2009-2013 Durran Jordan
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

$LOAD_PATH.unshift(File.dirname(__FILE__))

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), "app/models")
$LOAD_PATH.unshift(MODELS)

Dir[File.join(File.dirname(__FILE__), "..", "lib", "*.rb")].each {|file| require file }

if ENV["CI"]
  require "simplecov"
  require "coveralls"
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter "spec"
  end
end

require "mongoid"
require "rspec"

ENV["MONGOID_SPEC_HOST"] ||= "localhost"
ENV["MONGOID_SPEC_PORT"] ||= "27017"

HOST = ENV["MONGOID_SPEC_HOST"]
PORT = ENV["MONGOID_SPEC_PORT"].to_i

def database_id
  "mongoid_test"
end

def database_id_alt
  "mongoid_test_alt"
end

CONFIG = {
  sessions: {
    default: {
      database: database_id,
      hosts: [ "#{HOST}:#{PORT}" ]
    }
  }
}

# Can we connect to MongoHQ from this box?
def mongohq_connectable?
  ENV["MONGOHQ_REPL_PASS"].present?
end

def purge_database_alt!
  session = Mongoid::Sessions.default
  session.use(database_id_alt)
  session.collections.each do |collection|
    collection.drop
  end
end

# Set the database that the spec suite connects to.
Mongoid.configure do |config|
  config.load_configuration(CONFIG)
end

# Autoload every model for the test suite that sits in spec/app/models.
Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

module Rails
  class Application
  end
end

module MyApp
  class Application < Rails::Application
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular("canvas", "canvases")
  inflect.singular("address_components", "address_component")
end

RSpec.configure do |config|

  # Drop all collections and clear the identity map before each spec.
  config.before(:each) do
    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end

  # Filter out MongoHQ specs if we can't connect to it.
  config.filter_run_excluding(config: ->(value){
    return true if value == :mongohq && !mongohq_connectable?
  })
end
