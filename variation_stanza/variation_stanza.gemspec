# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'json'
metadata = open('./metadata.json') do |io|
  JSON.load(io)
end

Gem::Specification.new do |spec|
  spec.name          = 'variation_stanza'
  spec.version       = '0.0.1'
  spec.authors       = ['Keita Urashima']
  spec.email         = ['ursm@ursm.jp']
  spec.summary       = metadata["label"]
  spec.description   = metadata["definition"]
  spec.homepage      = ''
  spec.license       = metadata["license"]

  spec.files         = Dir.glob('**/*')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.4'
  spec.add_development_dependency 'rake'
end
