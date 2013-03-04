# -*- encoding: utf-8 -*-

# TODO: use require_relative
require File.expand_path('../lib/capistrano-unicorn/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'lunchbox-capistrano-unicorn'
  gem.version     = CapistranoUnicorn::VERSION.dup
  gem.author      = 'Jason Perkins'
  gem.email       = 'jperkins@gmail.com'
  gem.homepage    = 'https://github.com/jperkins/lunchbox-capistrano-unicorn'
  gem.summary     = %q{Unicorn integration for Capistrano}
  gem.description = %q{Capistrano plugin that integrates Unicorn server tasks.}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_runtime_dependency 'capistrano'
end