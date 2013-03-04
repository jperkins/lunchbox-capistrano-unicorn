


# Issue 47

source: https://github.com/sosedoff/capistrano-unicorn/pull/47

"Configurable Roles"

I have added a new commit which incorporates some fixes from my last commit. I
didn't intend for this to gain any type of attention (sorry for that) so I had
some errors in the code that I committed that had to be fixed. I also updated
the documentation to add the new option and describe the default behavior
which is to perform tasks on the :app role. I also bumped the version number
to 0.1.7.

Thanks,
Jack

# -----

This sounds useful; please can you rewrite the commit message to include an
explanation of the motivation for the feature, add a corresponding tweak to
the docs, and then submit a pull request?

# -----

I think this makes scarver2/capistrano-unicorn@a1b8e5b redundant.

# -----

I havent tested this yet. I'll submit a pull request asap when im sure it
works 100%.

# -----

Cool, thanks :)

# -----

@DaRizat Take a look at my latest commit. I implemented your method of setting
the :unicorn_role. I renamed the roles method because it was interfering with
roles in Capistrano. I removed the lambda too. I also removed the whitespace
and line feeds from the shell scripts for readability. I've done several
deployments this afternoon with the new code and it appears to be functioning
well. https://github.com/scarver2/capistrano-unicorn

# -----

Yes, I had a fix for that roles collision as well. I didn't really expect this
to generate any type of attention or discussion so I hadn't gotten back to
taking care of this. I didn't intend for this to be out in the wild today, but
you can't stop the power of the open source community :). I incorporated your
changes minus the whitespace adjustments. If you want to get those in a
separate pull request that would be fine.

# -----

FYI As with several Capistrano extensions and multistage, the set
:unicorn_role, :web needs to appear before require 'capistrano/ext/multistage'
and require 'capistrano-unicorn' in deploy.rb.

# -----

If you have time, would you replace the lambdas in the task definitions and
see if this corrects this behavior? I took that from the delayed job recipes,
and I believe that forces the expression to be evaluated at run time which
could theoretically remove the restriction you mentioned.

# -----

Had to rename the roles def which was causing a naming collision within
Capistrano. Removed the lambda function that was borrowed from delayed_job
recipe.


# Issue 46

source: https://github.com/sosedoff/capistrano-unicorn/issues/46

It's not at all clear why we need three variables which apparently serve the
same purpose:

    rails_env
    unicorn_env
    app_env

If they are really all necessary and serve different purposes then they should
be documented properly. Otherwise they should be collapsed to just one
variable, or two at most (since I can just about imagine that someone might
want `unicorn_env` to have a different value to `rails_env`).


# Issue 45

source: https://github.com/sosedoff/capistrano-unicorn/issues/45

I just looked at the github network graph and was disappointed to see a huge
number of forks with unmerged patches, mostly without corresponding pull
requests. Everybody loses out badly through this fragmentation, so it should
be discouraged.

Suggested actions:

* update the README to ask people to submit pull requests
* add comments to commits in forked repositories asking the author to submit a
  pull request
* proactively merge from forks back into this repo
* make a new release

Thanks for listening!


# Issue 44 

source: https://github.com/sosedoff/capistrano-unicorn/pull/44

Fixed `current_path` fetching with capistrano/multistage

If using capistrano with multistage and set `deploy_to` variable in
`deploy/production.rb` and `deploy/staging.rb`, then `current_path` on
unicorn's tasks will be `/u/apps/`. Maybe it's capistrano's bug, but this PR
fixes that.

Also, removed some rescue calls.


# Issue 43 

source: https://github.com/sosedoff/capistrano-unicorn/pull/43

"Ability to launch Unicorn as a different user than the deployer"

With this change, `capistrano-unicorn` can run Unicorn master (and there
Unicorn slaves) as a different user than the deployer.

Sometimes people prefer to use a privileged user for deploying apps and a
less-privileged user for running apps. With this change, they can.

Here's how:

    # Run Unicorn as the :runner user ("app" by default)
    set :unicorn_runner, true 

    # So deployer can launch Unicorn as the :runner user
    set :use_sudo, true       
    
    # Optionally override Capistrano's :runner variable
    # set :runner, "web"      

This feature relies on Capistrano's existing `:runner` setting, which is the
name of the user who will be running the web app. It defaults to `app` but can
be overridden with `set :runner, "username"` or you can use a string to choose
which user rather than relying on Capistrano's `:runner`:

    # Run Unicorn as the "web" user
    set :unicorn_runner, "web"  

    # deployer launchs Unicorn as the :runner user
    set :use_sudo, true         

The new `unicorn_runner` setting defaults to false, keeping is the existing
behavior of `capistrano-unicorn`.

Resolves issue sosedoff/capistrano-unicorn#22.


## File Permission Issues

By the way, when Unicorn runs as a different user there are some file
permissions that need to be fixed up. I did not include this in the pull
request because I wasn't totally sure if it was generally applicable. But I
think it is.

To be specific, the `unicorn_runner` user needs to be able to write to the
`tmp` directory. And in some apps (e.g., apps that use CarrierWave for
uploads), that user also needs to be able to create new subdirectories under
public.

Here's what I did in my local deploy script. If you think this should be
embedded in the pull request that's fine, or it could be added to the README:

    namespace :deploy do
      before "deploy:start",   "deploy:fix_permissions"
      after  "deploy:restart", "deploy:fix_permissions"

      task :fix_permissions, :roles => :app, :except => { :no_release => true } do
        run "#{try_sudo} chmod 775 #{current_path}/tmp"
        run "#{try_sudo} chmod 775 #{current_path}/public"
        run "#{try_sudo} chown #{user}:#{fetch(:unicorn_runner)} #{current_path}/tmp"
        run "#{try_sudo} chown #{user}:#{fetch(:unicorn_runner)} #{current_path}/public"
      end
    end

Note that the way I wrote `fix_permissions` only works if `unicorn_runner` is
a user name, not true. It would have to be modified to support true.

# ----- #

Also, why not use `unicorn_user` definition instead ?

# ----- #

Good question. I used `unicorn_runner` to follow the Capistrano convention,
where they use runner to indicate the username of the use will run the web
app.

I found the convention by looking at Capistrano's `try_runner` method, which
looks for a variable called `:runner`. The try_runner comment says:

    > Same as sudo, but tries sudo with `:as` set to the value of the
    `:runner` variable (which defaults to "app").


But a Google search indicates that use of "runner" doesn't seem widely used,
and it also seems to have a dual purpose: 

* for running deploy-time commands
* for running the app. 

I think it makes sense to skip it altogether and just call it `unicorn_user`,
and require a string (not support having true fall back on runner).

If you're in favor of that, I would be happy to make the change and test it
with my app that is using my branch.

# ----- #


I think the best approach here would be a double-fallback. So we check if
`unicorn_user` is defined first, then fallback to `unicorn_runner` and vise
versa.

This would allow people to use both without confusion.

Thoughts ?

# ----- #

No, if I understand you right I don't think anyone would use `unicorn_runner`
without being told to by some documentation somewhere. It's not something that
ever existed before. So I don't think falling back on it serves any purpose.
It just ends up allowing two variable names for one thing.

There is potential value in falling back on runner, which is why I did that in
my original pull request, since it's an existing concept.

How about this: I'll change the variable name to `unicorn_user` since that's a
more obvious/clear name, and take out support for true to fallback on runner.
If someone wants it to be the same as runner they can just set it to be the
same.

# ----- #


Ok, that'll work for me.

# ----- #

I made the change but have not yet tested it. Check it out, but give me a
minute.

I also improved something else. I felt weird about forcing people to set
`use_sudo` to true just for this one feature. But I realized that if I change
`try_sudo` to `sudo`, there's no need to force them to change another global
setting in their cap script.

`sudo` will always use `sudo`, regardless of any other variable settings.

This makes the setting less intrusive.

# ----- #

I tested the change. It works.


# Issue 42

source: https://github.com/sosedoff/capistrano-unicorn/pull/42

"Add unicorn duplicate task"

When using the Github recommended procedure for unicorn zero downtime
deployment also mentioned in this rails cast, You want the old unicorn master
quitting to be handled by the "before_fork" hook in the unicorn.rb config
file. In order for us to do that we need a task that won't kill the old master
just duplicate it.


# Issue 40

source: https://github.com/sosedoff/capistrano-unicorn/issues/40

`unicorn:restart` sends `QUIT` to old master before new master's workers are up

First, thanks for the lib, this is pretty handy. Just a quick question. I saw
this pull request merged in that I think added this behavior:

    https://github.com/sosedoff/capistrano-unicorn/issues/26

And in the sample unicorn file here there is also a QUIT sent to the old master:

    https://github.com/sosedoff/capistrano-unicorn/blob/master/examples/rails3.rb

When I run cap `unicorn:restart` the task properly sends the `USR2` to the old
master, sleeps 2 seconds, then sends a `QUIT` to the old master. At this
point, the workers of the new master are not yet up, so there are no workers
left to handle the request, and web browsers that had started a request sit
idly by. If one of the useful things of Unicorn is to have no downtime for
handling requests, why is this the behavior? I'm a bit new to Unicorn as well,
so please let me know if I have the wrong expectation here. Thanks.


# Issue 36

source: https://github.com/sosedoff/capistrano-unicorn/issues/36

"Known problems with capistrano multistage should go into the README"

Please add the information from your blog post to the README or at least link
to it.

# -----

pull requests are welcome

# -----

I took the freedom to add the information from your blog post to the
capistrano-unicorn wiki. I can also send you a pull request with an updated
README that will link to the wiki page.

Is that OK with you?

# -----

Yes! Thanks for doing it.

# -----

I've encountered this too. Should the gem just use unicorn_env instead of all
three?

# -----

Yes @ealden. That would have been my next question :)

# -----

According to #37 this is now fixed - @sosedoff please can you close it? And
@ealden if by "all three" you mean rails_env, unicorn_env, and app_env then I
agree, it seems ridiculous to have three variables and I have submitted #46
for this.



# Issue 33

source: https://github.com/sosedoff/capistrano-unicorn/issues/33

"unicorn:reload sometimes doesn't kill the old pid"

I'm having a problem where unicorn:reload is giving me two live unicorn
instances (sometimes of different versions!)

I'm sure the base cause for this is a bug in unicorn regarding the USR2
signal... however, I'd love if there were a config option to expand
unicorn:reload to unicorn:stop+unicorn:start for verbosity's sake.

Unfortunately, either way means I won't be updating my on the fly without
downtime.

# -----

I have discovered the same issue. Works fine for 1 app and then for the other
app I end up with "old" instances.

# -----

Are you using master or 0.1.6 gem ?

# -----

I tried both your gem and directly from master. I assume the gem was 0.1.6
(latest, right?)

# -----

I am going to try and debug this today. Will make a Pull Request if I get anywhere

# -----

Ok, I think the current master branch solves most issues. I solved my issues
by putting this in my Gemfile:

    gem 'capistrano-unicorn', github: "sosedoff/capistrano-unicorn", branch: "master", :require => false

I had tried to do this before but with little success. Turned out it was still
pointing at a different gem version in the global gemset. I recommend anyone
to run the commands as:

    bundle exec cap deploy

You can tell the difference between the current gem and the version in master
by looking at the output of cap -T

    # output from old gem
    cap unicorn:graceful_stop             # Unicorn graceful shutdown
    cap unicorn:reload                    # Reload Unicorn
    cap unicorn:start                     # Start Unicorn
    cap unicorn:stop                      # Stop Unicorn

    # output for master version
    cap unicorn:add_worker                # Add a new worker
    cap unicorn:reload                    # Reload Unicorn
    cap unicorn:remove_worker             # Remove amount of workers
    cap unicorn:restart                   # Restart Unicorn
    cap unicorn:shutdown                  # Immediately shutdown Unicorn
    cap unicorn:start                     # Start Unicorn master process
    cap unicorn:stop                      # Stop Unicorn

# -----

Yes. Im running some deployment tests right now.

# -----

We ran into the same issue related to cap unicorn:reload with the latest gems.
On reload, it creates new unicorn master/worker processes. It doesn't kill the
old processes before starting the new ones. The pid(s) in the log files still
reflect the old unicorn process, so on a successive stop it stop(s) the old
process and the new unicorn process is left dangling.


# Issue 28

source: https://github.com/sosedoff/capistrano-unicorn/issues/28

"New release"

The recent gem is not based on the newest source. Would be great if you could
release a new gem version.

# -----

Been using the master branch for a while, and it's working great:-) No
showstoppers in there, but some nice fixes for multistaging etc.

Would appreciate a new release, too.

Thanks for this great gem!

# -----

Then maybe just release the new 0.2.0? Master Branch seem to be stable.

# -----

I havent implemented few features i wanted, but i guess i can release and add
it later. Should be up in a day or so.

# -----

Any news on the release date of the next version?


# -----

@sosedoff what else haven't you implemented? I just started using this gem and
I think it works quite well, and am interested in helping in any way I can.

# -----

four months later, no change?

# -----

Aha! What gets installed is completely unlike master. Can you please release a
new version. thanks.

# -----

New release is coming this weekend. I stopped using capistrano and unicorn for
a while, there are many reasons to that, but i'll test and check that
everything works.

Some of the problems i've experienced are related to worker freeze issue,
which is a big deal when you're running a single server (~ 2GB ram) that has a
preload_app strategy enabled. This causes an unexpected memory overhead like
having a 2x amount of workers running at the same time. The system goes into
huge overload and eventually eats up all available memory, jumping all over
the swap buffer. Most problems are encountered on bigger apps that use lots of
third-party API's, on smaller apps everything works smooth since there are not
much to load into application.

# -----

Thanks.

Would be great if you could also look into #42, before publish the gem.

# -----

Please release it, thanks


# Issue 7

source: https://github.com/sosedoff/capistrano-unicorn/issues/7

"You should set the pid path via the command line..."

# -----

It'd be better if the pid path was set via the command line to match the value
in the Capfile.

# -----

Maybe a little explanation here? Not getting the case

# -----

I converted a simple capistrano recipe to use unicorn via your gem.

Every time I ran cap deploy it said it couldn't find the PID file.

My `config/unicorn/production.rb` file only contained a listen and
worker_processes directive.

to make it able to find the pid file, I had to add 

    pid File.expand_path('../../../tmp/pids/unicorn.pid', __FILE__)

Before I added the above line, I couldn't find a *.pid file anyplace in my
account, so I don't think unicorn even wrote a pidfile.

# -----

You can check out the example:

    https://github.com/sosedoff/capistrano-unicorn/blob/master/examples/rails3.rb

I dont think its a good idea to pass unicorn pid directly via command line,
easier just to define it in your unicorn config.

# -----

Hmm.... if it could detect it was missing and complain, it would be good.

An idea:

In the code I just submitted, there is a while loop that looks for a new_pid.
I could add that to the end of unicorn:start and if it doesn't appear, I could
complain some how and include instructions for how to fix it (create a file
`config/unicorn/foo.rb` and add pid ... to it).

Or maybe use a regex to see if it's set.

Ideally, the `set :unicorn_pid` directive would be obsolete because it could
identify the pidfile somehow.

# -----

Okay, here's how you can get the pidfile out of the configuration.....

Assuming your real unicorn config file is config/unicorn/production.rb you can
use this as a configuration file (pass it in via unicorn -c) and it'll print
out the pidfile location:

    config_file = "config/unicorn/production.rb"
    instance_eval(File.read(config_file), config_file) if config_file

    puts set[:pid]

    exit(0)

You just have to verify it's set to something and if it isn't, then raise a
stink (or error) about it.

# -----

Maybe I'm missing something because I'm not sure why this issue was closed -
there seems to be a contradiction between the docs and actual out-of-the-box
behaviour:

If I create an empty unicorn config file and do `cap unicorn:start`, unicorn
starts without a pid file. 

This contradicts the README.md which says Default to
`current_path/tmp/pids/unicorn.pid`.

On the other hand if `unicorn_pid` is really a mandatory option then I agree
100% with @docwhat that `cap unicorn:start` should not succeed without it, and
the docs should emphasise that it is required and not claim there is a
default.

Furthermore, if `unicorn_pid` is set to a different value than what's in the
unicorn config, then this gem will not work correctly. 

So again @docwhat is correct that this gem needs to automatically detect the
value from the unicorn config, rather than expect the user to correctly
configure the same value in `deploy.rb`, since the latter violates the two
core principles of Rails: the DRY rule and Convention over Configuration.

So please can you reopen until this is fixed? Thanks!

# -----

Alright, reopening.

Having something like generating the unicorn config file on the fly (in case
if it does not exist) will help to get it started with zero configuration.

# -----

Thanks ;-)

> Having something like generating the unicorn config file on the fly (in case
if it does not exist) will help to get it started with zero configuration.

But that still won't fix the violation of the two core principles mentioned
above, e.g. if the unicorn config already existed, or if either the unicorn
config or capistrano config are modified so that the pid paths no longer
match.

