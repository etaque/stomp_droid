$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'stomping_ground/version'

Gem::Specification.new do |s|
  s.name        = "stomping_ground"
  s.version     = StompingGround::VERSION
  s.authors     = ["Francisco Trindade"]
  s.summary     = %q{Mock Stomp server to be used when testing stomp consumers}

  s.files         = Dir.glob('lib/**/*') 
  s.require_paths = ["lib"]

  s.add_development_dependency 'onstomp'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'json'
  s.add_development_dependency 'rake'

  s.add_runtime_dependency 'eventmachine'
end


