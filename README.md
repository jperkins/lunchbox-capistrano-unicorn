# Capistrano Unicorn

Capistrano plugin that integrates Unicorn tasks into Capistrano's `deploy.rb`.

## Installation

Install from Rubygems:

```
gem install capistrano-unicorn
```

To install using Bundler, modify your project's `Gemfile`:

```ruby
group :development do
  gem 'capistrano-unicorn', :require => false
end
```


## Usage

### Setup

In your application's `config/deploy.rb`, require `capistrano-unicorn`:

```ruby
require 'capistrano-unicorn'
```

Add the `unicorn:reload` (or `unicorn:restart`) task to the `deplay:restart`
hook:

```ruby
after 'deploy:restart', 'unicorn:reload'    # app is **not** preloaded
after 'deploy:restart', 'unicorn:restart'   # app is preloaded
```

Create a Unicorn configuration file at `config/unicorn/unicorn.rb`. A [sample
configuration][1] is provided. For more examples and configuration options,
please refer to the Unicorn documentation.

For use in an environment where Capistrano Multistage is in use, additional
configuration is required. Checkout the section of this document "Using
Capistrano Multistage with Capistrano Unicorn" for more information.


### Test

Ensure sure you're running the latest release:

```ruby
cap deploy
```

You can then test each individual task:

```ruby
cap unicorn:start
cap unicorn:stop
cap unicorn:reload
```

## Configuration

Within your `config/deploy.rb`, you can modify any of the following options:


### `unicorn_env`

Sets the environment for Unicorn to execute within. Defaults to `rails_env`.

### `unicorn_pid` - 

Sets the path to the Unicorn PID file. Defaults to
`current_path/tmp/pids/unicorn.pid`

### `unicorn_bin` - 

The Unicorn executable file. Defaults to `unicorn`.

### `unicorn_bundle`

The Bundler command for Unicorn. Defaults to `bundle`.


## Using Capistrano Multistage with Capistrano Unicorn

The issue is that Capistrano loads default configuration and then executes
your staging task and overrides previously defined variables. The default
environment before executing stage task is set to `:production`, so it will
use a wrong environment unless you take steps to ensure that `:rails_env`,
`:unicorn_env`, `:app_env` are set correctly.

Let's take a look at sample `config/deploy.rb` file:

```ruby
set :stages, %w(production staging)
set :default_stage, "staging"

require 'capistrano/ext/multistage'
```

You’ll need to add `config/deploy/staging.rb` and
`config/deploy/production.rb` files. One way to do this is to explicitly set
the per-environment variables in each of these files:

```ruby
set :domain,      "YOUR_HOST"
set :rails_env,   "staging"
set :unicorn_env, "staging"
set :app_env,     "staging"

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_to,   "/home/#{user}/#{application}/#{fetch :app_env}"
set :current_path, File.join(deploy_to, current_dir)
```

This should fix the problem with wrong `rails env` being passed to unicorn
server. However, this violates DRY since a lot of these lines will be
identical in each staging file. So it would be nicer to keep common settings
in `config/deploy.rb`, and only put stuff in each staging definition file which
is really specific to that staging environment. Fortunately this can be done
using the lazy evaluation form of set. So instead `config/deploy.rb` file would
contain something like:

```ruby
set :stages, %w(production staging)
set :default_stage, "staging"

require 'capistrano/ext/multistage'

set(:unicorn_env) { rails_env }
set(:app_env)     { rails_env }

role(:web) { domain }
role(:app) { domain }
role(:db, :primary => true) { domain }

set(:deploy_to)    { "/home/#{user}/#{application}/#{fetch :app_env}" }
set(:current_path) { File.join(deploy_to, current_dir) }
```

and `config/deploy/staging.rb` would only need to contain:

```ruby
set :domain,      "YOUR_HOST"
set :rails_env,   "staging"
```

Much cleaner!

[Original Blogpost][2] 


## Available Tasks

For a list of all Capistrano tasks available, run `cap -T`:

```ruby
cap unicorn:add_worker      # Add a new worker
cap unicorn:remove_worker   # Remove amount of workers
cap unicorn:reload          # Reload Unicorn
cap unicorn:restart         # Restart Unicorn
cap unicorn:shutdown        # Immediately shutdown Unicorn
cap unicorn:start           # Start Unicorn master process
cap unicorn:stop            # Stop Unicorn
```

## License

See LICENSE file for details.


[1]: https://github.com/sosedoff/capistrano-unicorn/blob/master/examples/rails3.rb "sample capistrano-unicorn configuration"
[2]: http://blog.sosedoff.com/2012/01/21/using-capistrano-unicorn-with-multistage-environment/ "capistrano unicorn with capistrano multistage"




