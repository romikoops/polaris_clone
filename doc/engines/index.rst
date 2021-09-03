Engines
#######

CBRA (or cobra) is an architecture where monolithic Rails application is split to
multiple Rails engines. This allows easy separation of responsibility, separating view,
services and data layer from each other.

Currently our application supports three different engine types and separation of logic.

.. uml::

  @startuml
  [Direct] as D
  [API Layer] as A
  [Service Layer] as S
  [Data Layer] as DL

  note as ND
   Engines providing endpoints and access directly to users
  end note

  note as NA
   API endpoints etc.
  end note

  note as NS
   All service objects, and business logic.
  end note

  note as NDL
   Database abstraction and 3rd party integrations.
  end note

  D -- A
  A -- S
  S -- DL

  D . ND
  A . NA
  S . NS
  DL . NDL
  @enduml

Data
====

Data engines are providing raw data. Models in data engines own database tables, manage
migrations and provide basic wrappers over accessing data. Data engines are allowed to
have ActiveRecord relationships across engines if required.

Service
=======

View
====

Creating New Engines
====================

Main application has custom Rails generator that allows to create new engines easily.
By simply running __engine__ generator:

.. code-block:: shell

    % rails g engine --help
    Usage:
    rails generate engine NAME [options]

    Options:
     [--skip-namespace], [--no-skip-namespace]  # Skip namespace (affects only isolated applications)
    -t, --type=TYPE                              # Engine type (options: api/service/data)

    Runtime options:
    -f, [--force]                    # Overwrite files that already exist
    -p, [--pretend], [--no-pretend]  # Run but do not make any changes
    -q, [--quiet], [--no-quiet]      # Suppress status output
    -s, [--skip], [--no-skip]        # Skip files that already exist

    This generators creates new CBRA engines

Engine type is mandatory argument and that defines what files are
generated in the new engine.

Dependencies
============

Engine is most likely requiring external dependencies as well other engines.

Other Engines
-------------

To use other engines in the runtime, add required engines in engine's `gemspec` file as
dependency:

.. code-block:: shell

    s.add_dependency "api_auth"
    s.add_dependency "organizations"

Add necessary other internal gems or engines to `Gemfile.runtime` with following
pattern:

.. code-block:: shell

    gem "ENGINE_NAME", path: "../ENGINE_NAME"
    eval_gemfile "../ENGINE_NAME/Gemfile.runtime"

External Dependencies
---------------------

Similar to other engines, external rubygems dependencies are added as
usual to gemspec. All external gems needs to be explicitly required in
`lib/ENGINE/engine.rb` file.

Documentation
=============

Everytime there is changes in engines or their gemspec, always
generate corresponding dependency graph with `rails docs:engines`.

Dependencies
============
.. uml:: graph.puml


.. toctree::
   :hidden:

   companies/index.rst
   journey/index.rst
