# Set up server

> Install PostgreSQL

https://www.postgresql.org/download/ Later on you might need to setup a specific role in the database in order to make it work with the application. https://stackoverflow.com/questions/11919391/postgresql-error-fatal-role-username-does-not-exist/25263322

---

> Make sure that postGIS is installed

---

> You need to have Ruby installed. I recommend to use the popular version manager „rbenv“ for that. Please follow the instructions here: https://github.com/rbenv/rbenv

---

> Run `git clone https://github.com/rbenv/rbenv-vars.git $(rbenv root)/plugins/rbenv-vars`

---

> After you have installed Ruby with rbenv, you need to install „bundler“:
`gem install bundler`

---

> Go into the root of our project and run
`bundle install` … this will install all gems/libraries needed for running the app (including Rails, excluding MongoDB). This might take some time.

---

> Install MongoDB Community Edition 3.6, please follow instructions here: https://docs.mongodb.com/manual/installation/

---

> Open a terminal and start MongoDB. It depends on how you specifically did setup Mongo, but I set it up to save the database "~/mongodb/db“. This can be different for you, depending on how you configured it. With my configuration, I start it with this command:
`mongod --dbpath ~/mongodb/db --bind_ip 127.0.0.1`, so I bind it to the localhost IP.

---

Now it’s time to get data into the database.

1. `rake db:create` to create the database in postgres.
2. `rake db:migrate` to create the database schema in postgres.
3. Now we fill the databases (both Postgres and MongoDB) with data (Mongo needs to be running!!)

3.1 `rake db:seed:demo` seeds everything but the trucking data, as this is quite a complex thing in itself.
3.2 `rake db:seed:trucking_destinations` takes between 30-60 minutes!!
3.3 `rake db:seed:trucking_pricing` can potentially also take a bit of time!

---

> start the app server by saying `rails server`

---

> cd into the „client“ folder and run `npm install` and finally `npm start`. Now the application should be running on localhost:8080!

## Reset database

> rake db:drop db:create db:migrate db:seed:geometries db:seed:incoterms db:seed:demo db:seed:trucking_pricing
