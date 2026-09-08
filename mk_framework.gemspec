# frozen_string_literal: true

require_relative 'lib/mk_framework/version'

Gem::Specification.new do |spec|
  spec.name = 'mk_framework'
  spec.version = MK::VERSION
  spec.authors = ['Francesco Canessa']
  spec.summary = 'Small, explicit JSON APIs on Roda'
  spec.homepage = 'https://github.com/makevoid/mk_framework'
  spec.description = 'Resource routing, controllers, and response handlers with optional Sequel persistence.'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'
  spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE', 'CHANGELOG.md', 'docs/*.md']
  spec.require_paths = ['lib']
  spec.add_dependency 'roda', '>= 3.92', '< 4'
  spec.add_dependency 'rack', '>= 3.2.7', '< 4'
  spec.add_dependency 'json', '>= 2.12', '< 3'
  spec.add_dependency 'logger', '>= 1.6', '< 2'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
end
