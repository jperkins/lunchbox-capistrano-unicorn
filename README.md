# Capistrano Unicorn

Capistrano plugin that integrates Unicorn tasks into Capistrano's `deploy.rb`.

## Installation

Install from Rubygems:

```
gem install capistrano-unicorn
```

To Install using Bundler, modify your project's `Gemfile`:

```ruby
group :development do
  gem 'capistrano-unicorn', :require => false
end
```


## Usage

### Setup

Load `capistrano-unicorn` in `config/deploy.rb`:

```ruby
require 'capistrano-unicorn'
```

Add Unicorn restart task to the `deplay:restart` hook:

```ruby
after 'deploy:restart', 'unicorn:reload'    # app is **not** preloaded
after 'deploy:restart', 'unicorn:restart'   # app is preloaded
```

Create a new configuration file `config/unicorn/unicorn.rb` or
`config/unicorn/STAGE.rb`, where stage is your deployment environment.

TODO: fix this link
Example config -
[examples/rails3.rb](https://github.com/sosedoff/capistrano-unicorn/blob/master/examples/rails3.rb).

Please refer to the Unicorn documentation for more examples and configuration
options.

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

You can modify any of the following options in your `deploy.rb` config.

### `unicorn_env`

Sets the environment for Unicorn to execute within. Defaults to `rails_env`
variable.

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

TODO: fix this link
Original Blogpost: http://blog.sosedoff.com/2012/01/21/using-capistrano-unicorn-with-multistage-environment/


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
