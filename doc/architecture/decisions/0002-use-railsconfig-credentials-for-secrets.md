# 2. Use RailsConfig TITLE Credentials For Secrets

Date: 2018-09-10

## Status

Accepted

## Context

We have lot of sensitive API Keys and Credentials that needs to be kept secure but also allowing easy management.
Each secret has different value depending on environment, mostly required passwords for review environment as well
for production environment.

## Decision

Rails 5.2 provides common Credentials support but this is flat file that doesn't support easily to fetch different
values for different Rails environment. It also encrypts all values, including public usernames etc. that makes
debugging and finding used credentials and user accounts much more difficult task.

Adopting RailsConfig gem on top of this allows easily to fetch only secrets from encrypted credentials, while keeping
the usernames etc as plain text.

## Consequences

Extra dependency of RailsConfig gem though it has been existing for ages and is well battle-tested.
