lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "panos/phpipam/version"

Gem::Specification.new do |spec|
  spec.name          = "panos-phpipam"
  spec.version       = Panos::Phpipam::VERSION
  spec.authors       = ["Yuri Zubov"]
  spec.email         = ["y.zubov@sumatosoft.com"]

  spec.summary       = %q{sdfsdfs sdfsdf sdfs sdf}
  spec.description   = %q{sdfsdfs sdfsdf sdfs sdf}
  spec.homepage      = "http://tut.by"
  spec.license       = "MIT"

  spec.executables   = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }

  spec.files = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rubocop", "~> 0.51.0"
  spec.add_runtime_dependency "ruby_phpipam", "~> 0.3.0"
  spec.add_runtime_dependency "crack"
  spec.add_runtime_dependency "mixlib-cli", '~> 1.7.0'
  spec.add_runtime_dependency "rest-client"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
