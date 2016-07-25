# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "gem-check"
  spec.version       = GemCheck::VERSION
  spec.authors       = ["Meissa Dia"]
  spec.email         = ["meissadia@gmail.com"]
  spec.license       = 'MIT'

  spec.summary       = %q{See the download counts of your owned gems.}
  spec.description   = %q{See the download counts (current version & total) of your owned gems.}
  spec.homepage      = "https://github.com/meissadia/gem-check"

  spec.files         = Dir.glob('{bin,lib}/**/*') + ['README.md', 'screenshot-gem-check.png']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "gems", "~> 0.8.3"
  spec.add_runtime_dependency "terminal-table", "~> 1.6"
end
