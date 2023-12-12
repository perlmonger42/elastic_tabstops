
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "elastic_tabstops/version"

Gem::Specification.new do |spec|
  spec.name          = "elastic_tabstops"
  spec.version       = ElasticTabstops::VERSION
  spec.authors       = ["Thomas A. Boyer"]
  spec.email         = ["thom at boyers.org"]

  spec.summary       = %q{An output stream that makes columnar output easy.}
  spec.description   = %q{Generate monospaced output in neatly-aligned columns.

This gem implements the Elastic Tabstops proposal
(see http://nickgravgaard.com/elastic-tabstops/).

Data written to an elastic tabstop output stream is reformatted to align
columns. Columns are made up of tab-terminated cells in adjacent lines of output.
}
  spec.homepage      = "https://github.com/perlmonger42/elastic_tabstops"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/perlmonger42/elastic_tabstops"
    spec.metadata["changelog_uri"] = "https://github.com/perlmonger42/elastic_tabstops/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-rg", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.12.2"
  spec.add_development_dependency 'pry-byebug', '~> 3.7', '>= 3.7.0'
  spec.add_development_dependency "ffaker", "~> 2.11", ">= 2.11.0"
end
