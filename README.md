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

Create a new configuration file `config/unicorn/unicorn.rb` or `config/unicorn/STAGE.rb`, where stage is your deployment environment.

Example config -
[examples/rails3.rb](https://github.com/sosedoff/capistrano-unicorn/blob/master/examples/rails3.rb).

Please refer to the Unicorn documentation for more examples and configuration
options.

### Test

Ensure sure you're running the latest release:

```
cap deploy
```

You can then test each individual task:

```
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

### Capistrano Multistage

If you are using capistrano-multistage, please refer to [Using Capistrano Unicorn with multistage environment](https://github.com/sosedoff/capistrano-unicorn/wiki/Using-capistrano-unicorn-with-multistage-environment).


## Available Tasks

For a list of all Capistrano tasks available, run `cap -T`:

```
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
