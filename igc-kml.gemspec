Gem::Specification.new do |s|
  s.name        = 'igc-kml'
  s.version     = '0.0.9'
  s.date        = '2012-07-09'
  s.summary     = "Convert .igc files to .kml"
  s.description = "Convert files in the avionics flight recorder data format (.igc) to keyhole markup language files (.kml) that can be displayed in Google Earth."
  s.authors     = ["Tobias Noiges"]
  s.email       = 'tobias@noig.es'
  s.files       = ["lib/igc-kml.rb"]
  s.homepage    = 'https://github.com/nokinen/igc-kml'
  s.add_runtime_dependency "builder", '~> 3.0.0'
  s.add_runtime_dependency "rake", '~> 0.9.2'
  s.executables << 'igc-kml'
end