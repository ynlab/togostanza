lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'environment_top_level_symbolic_image_nano_stanza'
  spec.version       = '0.0.1'
  spec.authors       = ['TODO: Write your name']
  spec.email         = ['']
  spec.summary       = %q{Environment Top Level Symbolic Image Nano}
  spec.description   = %q{NanoStanza: Display an symbolic image for the MEO's toplevel category related to the given MEO ID.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob('**/*')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'togostanza'
end
