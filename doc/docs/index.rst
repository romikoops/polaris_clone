=====================
Documentation Process
=====================

The purpose of the documentation process is to provide necessary information and
guidance to rest of the product team as well for rest of the business units.

Documentation for development projects are split to two parts:

:Technical:
  Technical documentation provides information for developers how to build
  software and best practises agreed as part of the team.

:Guides:
  Guides ar emeant for rest of the business units as guides how to use our
  software and provide necessary information for them to firstly succeed on
  their own work as well secondly provide necessary documentation to the our
  users.

---------
Locations
---------

Documentation is located as part of the code repository, and is split to two
similar directories as expected.

:``doc/``:
  This directory contains all technical documentation about Polaris project,
  such as instructions how to use techinical tools chosen for the project, as
  well for business logic that is required to understand current code.

:``guides/``:
  This directory contains overall guides which are meant for the rest of the
  business units.

---------------------
Writing Documentation
---------------------

Documentations are written using ``sphinx`` tool. Most of the pages are as
reStructured Text, but Markdown plugin is installed as well, so in preferred,
documentation can be written using markdown syntax as well.

^^^^^^^^^^^^^^^^^^^^
Adding Documentation
^^^^^^^^^^^^^^^^^^^^

To add new pages and sections to existing documentation, you are free to choose
any directory layout as necessary. To add new pages to be visible in the final
documentation, pages need to be included in ``toctree`` directive on the page
that would be parent page of new pages.

==========
Publishing
==========

GitHub Actions are configured to automatically generate and publish
documentation on deploy to Company's Confluence. Technical documentation and
guides are published on different spaces:

:Technical Documentation:
  These documentations are published on ``DEV`` space under ``Documentation``
  page.

:Guides:
  These documentation are published on ``KB`` space under ``Guides`` page.


.. toctree::
   :hidden:
