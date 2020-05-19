## Component Based Rails Applications (CBRA)

CBRA (or cobra) is an architecture where monolithic Rails application is split to multiple Rails engines.
This allows easy separation of responsibility, separating view, services and data layer from each other.

### Engine Types

Currently our application supports three different engine types and separation of logic.

    ┌──────────────┐
    │  View Layer  │ For example API endpoints, Admiralty etc.
    └──────────────┘
          │       
          ▼       
    ┌──────────────┐
    │Service Layer │ All service objects, and business logic.
    └──────────────┘
          │       
          ▼       
    ┌──────────────┐
    │  Data Layer  │ Database abstraction and 3rd party integrations.
    └──────────────┘    

#### Data

Data engines are providing raw data. Models in data engines own database tables, manage migrations and provide basic
wrappers over accessing data. Data engines are allowed to have ActiveRecord relationships across engines if required.

#### Service

#### View

### Creating New Engines

Main application has custom Rails generator that allows to create new engines easily. By simply running __engine__
generator:

    % rails g engine --help
    Usage:
    rails generate engine NAME [options]

    Options:
      [--skip-namespace], [--no-skip-namespace]  # Skip namespace (affects only isolated applications)
    -t, --type=TYPE                              # Engine type (options: view/service/data)

    Runtime options:
    -f, [--force]                    # Overwrite files that already exist
    -p, [--pretend], [--no-pretend]  # Run but do not make any changes
    -q, [--quiet], [--no-quiet]      # Suppress status output
    -s, [--skip], [--no-skip]        # Skip files that already exist

    This generators creates new CBRA engines

Engine type is mandatory argument and that defines what files are
generated in the new engine.

**Note**: Please note that engine gem name is prefixed with _imc-_ but engine and namespace is always without IMC prefix. For example _imc-tenants_ engine has namespace _Tenants_ only.

#### Dependencies

Engine is most likely requiring external dependencies as well other engines.

##### Other Engines

To use other engines in the runtime, add required engines in engine's `gemspec` file as dependency:

    s.add_dependency 'imc-api_auth'
    s.add_dependency 'imc-tenants'

Then add to `lib/<ENGINE NAME>/engine.rb` file necessary requires:

    require 'api_auth'
    require 'tenants'

All runtime dependencies are automatically required in engine's
Gemfile.

##### External Dependencies

Similar to other engines, external rubygems dependencies are added as
usual to gemspec. Similarly all gems needs to be required in `lib/<ENGINE NAME>/engine.rb` file.

## Documentation

Everytime there is changes in engines or their gemspec, always
generate corresponding dependency graph with `rails cobra:graph`.
