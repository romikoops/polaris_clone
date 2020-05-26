    _____ _       ___  ___      _____
    |_   _| |      |  \/  |     /  __ \
     | | | |_ ___ | .  . |_   _| /  \/ __ _ _ __ __ _  ___
     | | | __/ __|| |\/| | | | | |    / _` | '__/ _` |/ _ \
    _| |_| |_\__ \| |  | | |_| | \__/\ (_| | | | (_| | (_) |
    \___/ \__|___/\_|  |_/\__, |\____/\__,_|_|  \__, |\___/
                           __/ |                 __/ |
                          |___/                 |___/

# Development Setup

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

    # Download and seed slim version of database (only demo organization)
    $ bin/rake db:reload

    # Download and seed full version of database (all organizations)
    $ bin/rake db:reload:full

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

# :ship: Deployments

## Backend (Polaris)

We currently deploy API layer via AWS Elastic Beanstalk. Backend can be deployed
with Rake task:

    $ rails deploy:backend

## Frontend (Dipper)

Frontend is deployed with Helm chart:

    # Ensure you are in correct cluster:
    $ kubectx armada
    $ helm upgrade --atomic --namespace dipper dipper ../charts/stable/dipper --set image.tag=$(git rev-parse HEAD)
