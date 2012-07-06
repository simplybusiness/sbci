# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sbci/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Egils Muzis"]
  s.email         = ["egils.muzis@xbridge.com"]
  s.description   = "Utility to easily export or import and Jenkins job configuration"
  s.summary       = "Manage your Jenkins jobs through this easy to use command-line interface"
  s.homepage      = "https://github.com/simplybusiness/sbci"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = "sbci"
  s.require_paths = ["lib"]
  s.version       = SBCI::VERSION

  s.add_dependency "rest-client"
  s.add_dependency "grit"
  s.add_dependency "trollop"
  
  s.add_development_dependency "bahia"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "growl"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end
