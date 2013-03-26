$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'stomping_ground/version'

Gem::Specification.new do |s|
  s.name        = "stomping_ground-celluloid"
  s.version     = StompingGround::VERSION
  s.authors     = ["Francisco Trindade", "Geoffrey Giesemann", "Emilien Taque"]
  s.email       = ["francisco.trindade@rea-group.com", "geoffrey.giesemann@rea-group.com", "e.taque@alphalink.fr"]
  s.summary     = %q{Mock Stomp server to be used when testing stomp consumers, Celluloid::IO version.}
  s.homepage    = "http://github.com/etaque/stomping_ground"

  s.files         = Dir.glob('lib/**/*')
  s.require_paths = ["lib"]

  s.add_development_dependency 'onstomp'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'json'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'

  s.add_runtime_dependency 'celluloid-io'
end

