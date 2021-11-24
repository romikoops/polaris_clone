API
================================

**This engine is primarily responsible, for providing endpoints that our
frontend apps can use, to access data for:**

**Shipment Request endpoints**

- GET - Retrieves a Shipment Request instance, with the given shipment request id.
- POST - Creates a Shipment Request instance, along with some contact information about the client, and commodity information.

**Schedules Request endpoints**

- GET - Retrieves a list of schedules queried by the organization and result params.

Schedules are queried from the information available from the journey models using the attributes:
organization_id, origin, destination, closing_date, carrier, service, and mode_of_transport.

**Colli Types Request endpoints**

- GET - Retrieves a list of colli types queried by the organization.

**Login Request endpoints**

- GET *validate_email* - Verifies if email is valid i.e Users::User with the specified email is present in the system and returns the following information.

+-------------------+------------------------------------------------------------------------------------+
| **response data** |                                   **definition**                                   |
+===================+====================================================================================+
| firstName         | first name of the user with the specified email.                                   |
+-------------------+------------------------------------------------------------------------------------+
| authMethods       | returns the supported auth methods for the user which depends on the organization. |
+-------------------+------------------------------------------------------------------------------------+
| samlIntegrations  | Information required to display the saml button on the front end                   |
+-------------------+------------------------------------------------------------------------------------+