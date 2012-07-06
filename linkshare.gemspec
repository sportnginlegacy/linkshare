# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "linkshare/version"

Gem::Specification.new do |s|
  s.name        = "linkshare"
  s.version     = Linkshare::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ian Ehlert"]
  s.email       = ["ian.ehlert@tstmedia.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby gem to hit the Linkshare report api.}
  s.description = %q{Ruby gem to hit the Linkshare report api.}

  s.rubyforge_project = "linkshare"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency(%q<httparty>)
end
