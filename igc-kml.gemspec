Gem::Specification.new do |s|
  s.name        = 'igc-kml'
  s.version     = '0.0.0'
  s.date        = '2012-05-29'
  s.summary     = "Convert .igc files to .kml"
  s.description = <<-EOF
    A simple gem to converter signed .igc files to unsigned .kml
    files that can be displayed e.g. in Google Earth.
  EOF
  s.authors     = ["Tobias Noiges"]
  s.email       = 'tobias@noig.es'
  s.files       = ["lib/igc-kml.rb"]
  s.homepage    = 'https://github.com/nokinen/igc-kml'
  s.add_runtime_dependency "builder"
  s.executables << 'igc-kml'
end