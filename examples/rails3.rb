# -----------------------------------------------
# Sample Unicorn Configuration for a Rails 3 App
# -----------------------------------------------

# Absolute path to the application.
app_path = "/path/to/app"

# Unicorn options
worker_processes 1
preload_app true
timeout 180
listen "127.0.0.1:9000"

# Spawn Unicorn master worker for the user `apps` with
# a group of `apps`.
user 'apps', 'apps'

# Absolute path to the application
working_directory app_path

# Set the environment for Unicorn to execute within.
rails_env = ENV['RAILS_ENV'] || 'production'

# Paths for Unicorn's logging.
stderr_path "log/unicorn-stderr.log"
stdout_path "log/unicorn-stdout.log"

# Location of Unicorn's master PID file
pid "#{app_path}/tmp/pids/unicorn.pid"


# TODO: add comment
before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"

  # TODO: confirm this works
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

# TODO: add comment
after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end