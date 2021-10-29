# frozen_string_literal: true

require_relative "lib/oura_ring_api/version"

Gem::Specification.new do |spec|
  spec.name          = "oura_ring_api"
  spec.version       = OuraRingApi::VERSION
  spec.authors       = ["Iori OSADA"]
  spec.email         = ["iori.osada@gmail.com"]

  spec.summary       = "This gem gives you a client to handle communicating with OuraRing via API."
  spec.description   = "This gem gives you a client to handle communicating with OuraRing via API."
  spec.homepage      = "https://github.com/iorin0225/oura_ring_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/iorin0225/oura_ring_api"
  spec.metadata["changelog_uri"] = "https://github.com/iorin0225/oura_ring_api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'oauth2', '~> 1.4.0'
  spec.add_dependency 'faraday', '~> 0.12.2'
  spec.add_dependency 'faraday_middleware', '~> 0.12.2'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
