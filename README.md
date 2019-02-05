# ItsMyCargo

## :ship: Deployments

We currently deploy API layer via AWS Elastic Beanstalk.
Frontend code is deployed by manually via `npm deploy` script in `client/` directory.

## Development Setup


### Initial Database

To seed initial development database, we have nightly database dump of production system that is anonymised and cleaned
for development usage. To download and seed local database with this seed file, please ask from the colleague the
service account JSON credentials and save the file as `$HOME/.gcloud_developer.json`. Alternatively you can point
rake task to use any other service account JSON credentials file that has required permissions by setting environment
variable `GOOGLE_CLOUD_KEYFILE` to pointing correct filename.

After this, simply run rake task:

    $ bin/rake db:drop db:import

### Overcommit

We use [overcommit](https://github.com/brigade/overcommit) to maintain our git hooks. Currently only commit message format
is enforced with pre-commit hooks, but other mandatory checks can be added if required.

First install `overcommit` globally: `gem install overcommit` and then simply install overcommit hooks with
`overcommit --install`.
Sometimes overcommit will make life difficult, i.e. when rebasing and rebase contains overcommit config file changes.
These cases Overcommit will fail and abort rebasing process. These cases Overcommit can be disabled by setting environment
variable `OVERCOMMIT_DISABLE=1`, e.g. to rebase:

    OVERCOMMIT_DISABLE=1 git rebase -i origin/master

#### Commit Message

Please keep your commit message sensible and descriptive. For example of what is considered good git commit message,
please see [Linus' instructions](https://github.com/torvalds/subsurface-for-dirk/blob/master/README#L92). Each commit
message should adhere to the following pattern:

    IMC-123 Summary: explain the commit in one line (use the imperative)

    Body of commit message is a few lines of text, explaining things
          in more detail, possibly giving some background about the issue
          being fixed, etc etc.

This allows us to quickly look through our git history and see relevant changes or commits - as well see more detail on said change (if applicable). For JIRA to link commits and PRs to tickets, each commit must have a JIRA ticket key. In the case that there is no JIRA ticket, you should either create one, or use one of following prefixes:

  * `HOTFIX:` - Hotfixing broken master
  * `WIP:` - The commit is a work in progress
  * `CHORE:` - The commit is a quick chore or task and does not directly relate to any ticket (such as README cleanups etc)

All prefixes are case insensitive.
