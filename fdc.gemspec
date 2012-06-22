Gem::Specification.new do |s|
  s.name        = 'fdc'
  s.version     = '0.0.4'
  s.date        = '2012-06-21'
  s.summary     = "Convert flight data format files (IGC) to keyhole markup language (KML)"
  s.description = "Convert files in the avionics flight recorder data format (IGC) to the keyhole markup language (KML) for display in applications such as Google Earth."
  s.authors     = ["Tobias Noiges"]
  s.email       = 'tobias@noig.es'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/nokinen/fdc'
  s.add_runtime_dependency "builder", '~> 3.0.0'
  s.add_development_dependency "rake", '~> 0.9.2'
  s.add_development_dependency "gem-licenses", '~> 0.1.2'
  s.executables << 'fdc'
end