```
             .        ___  ___  _      _   ___ ___ ___
             ;       | _ \/ _ \| |    /_\ | _ |_ _/ __|
         - --+- -    |  _| (_) | |__ / _ \|   /| |\__ \
  .          !       |_|  \___/|____/_/ \_|_|_|___|___/
.            .      
 +
```

## Git hooks

We use [lefthook](https://github.com/Arkweid/lefthook) for managing common Git
hooks. After installing all gems (via `bundle install`), always remember to
install lefthook as well:

    bundle exec lefthook install -f

## Database Seeds

To seed development database, we have nightly database dump of production system
that is anonymised and cleaned for development usage.

To download and seed local database with this seed file, please ensure you have
set up your own Amazon AWS Access Keys properly.

After this, simply run rake task:

    $ bin/rake db:reload

## Docker Based Development

As our backend system grows more complicated with more dependencies,
we have prepared simple Docker Compose based development system.
To use it, always wrap necessary docker-compose commands with `bin/docker-compose`. This
is simple wrapper script that automatically ensures that docker environment has correct
AWS Access keys defined.

To begin, make sure you have build required base image first for docker-compose:

    bin/docker-compose build --pull

After this you can do easily following operations (and much more):
* Install gems: `bin/docker-compose run polaris bundle`
* Reload database from development seed: `bin/docker-compose run polaris bundle exec rails db:reload`
* Migrate database: `bin/docker-compose run polaris bundle exec rails db:migrate`
* Rails console: `bin/docker-compose run polaris bundle exec rails c`

* Setup development server: `bin/docker-compose up`

* Stop development server: `bin/docker-compose stop`
* Start development server: `bin/docker-compose start` (after stop)

* Tear down development server: `bin/docker-compose down -v`

## Commit Message

Please keep your commit message sensible and descriptive. For example of what is
considered good git commit message, please see
[Linus' instructions](https://github.com/torvalds/subsurface-for-dirk/blob/master/README#L92).
Each commit message should adhere to the following pattern:

    IMC-123: explain the commit in one line (use the imperative)

    Body of commit message is a few lines of text, explaining things
          in more detail, possibly giving some background about the issue
          being fixed, etc etc.

This allows us to quickly look through our git history and see relevant changes
or commits - as well see more detail on said change (if applicable). For JIRA to
link commits and PRs to tickets, each commit must have a JIRA ticket key. In the
case that there is no JIRA ticket, you should either create one, or use one of
following prefixes:

  * `hotfix:` - Hotfixing broken master
  * `wip:` - The commit is a work in progress
  * `chore:` - The commit is a quick chore or task and does not directly relate
    to any ticket (such as README cleanups etc)

All prefixes are case insensitive.

## Master Key

When developing you may run into an error saying `client_secret is missing` on
certain parts of the site, for example at `localhost:3000/admiralty`.
Ask another member of dev team to get the master key.
