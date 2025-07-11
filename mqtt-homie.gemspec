lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mqtt/homie/version"

Gem::Specification.new do |spec|
  spec.name = "mqtt-homie"
  spec.version = MQTT::Homie::VERSION
  spec.authors = ["Andrew Williams"]
  spec.email = ["sobakasu@gmail.com"]

  spec.summary = %q{A ruby interface for creating a device conforming to the MQTT Homie convention.}
  spec.homepage = "https://github.com/sobakasu/mqtt-homie"
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sobakasu/mqtt-homie"
  spec.metadata["changelog_uri"] = "https://github.com/sobakasu/mqtt-homie/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "mqtt", "~> 0.6"
  spec.add_dependency "sys-uname"
  spec.add_dependency "macaddr"
end
