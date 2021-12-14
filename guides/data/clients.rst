Clients
=========

Client is an entity that represents an agent in our system. Clients
belongs always to one organization.

Sheet
-----

The Excel sheet must have following columns:

:EMAIL:
  **(required)** Email address of the user

:FIRST_NAME:
  **(required)** First name of the user

:LAST_NAME:
  **(required)** Last name of the user

:COMPANY_NAME:
  **(optional)** Name of the user's company

:PHONE:
  **(optional)** Contact number of the user

:EXTERNAL_ID:
  **(optional)** User's external id

:PASSWORD:
  **(optional)** User's password

:CURRENCY:
  **(optional)** User's chosen currency. Note that if no currency is provided, the default value will be the currency of their organization

:LANGUAGE:
  **(optional)** User's chosen language. Note that if a language is chosen other than en-US, es-ES and de-DE, an error will be raised stating that the language must be one of those three choices


Uploading a sheet
-----------------

To upload the Companies sheet, first log in as an Admin user then make your way to
the Clients page. In the Upload Data box click "Upload". After the
upload completes you will receive an email with the results of the process.
