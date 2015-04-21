# Joist - Bidding System Application

This is a working rails application built as a programming exercise. Deploying this application creates an API to respond to specific HTTP GET requests, as defined through the provided documentation (not included).  

All responses have the following structure:


    {
	    result : success | error
	    data : null | {}
	    error : null | error\_content
    }

## Requests

Note that all actions except for the *finish* action route to the User Controller. The *finish* action is handled by the Auction Contoller. The API will respond to the following HTTP GET requests:

    /add_user?user_id=1&budget=1000
Adds a new user to the system

    /add_item?user_id=1&item_name=book&start_price=10
Adds a new item to the system. This item will belong to the User with the given id, and will create an auction for the new item.

    /bid?user_id=1&item_id=3&amount=15
Places a bid for the User with user\_id for the Item with item\_id and the specified amount.

    /finish?item_id=1
Ends the auction for Item with item\_id. 

    /snapshot
Returns the current structure of Auctions and Users.


## Ruby version

Application was created with: 'Ruby 2.1.0'


## System dependencies

See Gemfile for dependencies


## Configuration

Application has two main controllers. See 'routes.rb' for mappings of requests to controller actions. 

* Database creation and initialization

This application runs on PostgreSQL (v9.3.1). To get started, navigate to the application directory and run:
    bundle install
    rake db:create db:migrate    

Database schema can be found in:
```db/schema.rb```

Run tests using:
```rake test``` or simply ```rake```

Launch a server with:
```rails server```

## Getting started

Ensure that Rails 4.0.2, Bundler 1.5.2 and PostgreSQL 9.3.1 or later are installed. Fork or unzip the program and run:
    
    bundle install    
    rake db:create    
    rails s    
    
Your application should be up and running!

## Additional notes

All currencies in the system were changed from integers to decimal places, using the BigDecimal library. This allowed me to build/learn more interesting tests and validations.

Read-repeatable transaction isolation levels were used in the application. Simply, this isolation level ensures that database rows that are to be updated have not changed since permission was obtained to changed them. 

TODO: This application is not RESTful. Creating new Users, Items etc should be resolve by HTTP POST commands with corresponding and appropriately named Rails Controller Actions to follow best practices. 

This was fun! Building this application out was an excellent excuse to dive into the Postgres documentation, develop a deeper understanding of how transaction isolation levels are employed within Rails, etc. Also, I struggled early on to define a how I wanted to use exceptions as well as how I wanted to implement a consistent response object - more great learning! Thanks Mike!


