lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'gene_length_nano_stanza'
  spec.version       = '0.0.1'
  spec.authors       = ['Toshiaki Katayama']
  spec.email         = ['ktym@dbcls.jp']
  spec.summary       = %q{NanoStanza for showing gene length.}
  spec.description   = %q{Total length of a gene region including exons and introns.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob('**/*')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'togostanza'
end
