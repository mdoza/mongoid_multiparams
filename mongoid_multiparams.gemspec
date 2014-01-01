# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_multiparams/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid_multiparams"
  spec.version       = MongoidMultiparams::VERSION
  spec.authors       = ["Matt D"]
  spec.email         = ["mdoza@me.com"]
  spec.description   = %q{Multi parameter support for Mongoid.}
  spec.summary       = %q{As of Mongoid 4.0.0, multi parameter support had been removed. This gem replaces the missing functionality.}
  spec.homepage      = "http://github.com/mdoza/mongoid_multiparams"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "mongoid", '~> 4.0.0.alpha1'
  
  # signing key and certificate chain
  # TODO: Will deal with this later.
  # spec.signing_key = '/Users/matt/.security/gem-private_key.pem'
  # spec.cert_chain  = ['gem-public_cert.pem']
end
