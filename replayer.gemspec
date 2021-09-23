# frozen_string_literal: true

require_relative "lib/replayer/version"

Gem::Specification.new do |spec|
  spec.name          = "replayer"
  spec.version       = Replayer::VERSION
  spec.authors       = ["Giuliano Mega"]
  spec.email         = ["giuliano.mega@gmail.com"]
  spec.summary       = "Method Record/Replay for Ruby"
  spec.description   = <<-eof
    Write description here.
  eof
  spec.homepage      = "https://github.com/gmega/replayer-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.3")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
end

