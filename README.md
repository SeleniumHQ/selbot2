# Selbot2
IRC bot for the #selenium channel on freenode.

## Database

The bot utilizes a PostgreSQL database for persisting data. 
Follow the [installation guides](https://wiki.postgresql.org/wiki/Detailed_installation_guides) for help getting setup locally.

A database needs to be created and the DATABASE_URL environment variable needs to be set. Typically, localhost is used for development:
  
    DATABASE_URL=postgres://localhost/database
    
For use in production, the url should be in the form:

    DATABASE_URL=postgres://user:password@host:port/database

Required tables will be genereted automatically by the app.

## Startup

To run the bot locally, try:

    $ bundle install
    $ SELBOT_CHANNEL=#my-test-channel bundle exec ruby -I lib bin/selbot2.rb
    
Note that startup is for unknown reasons quite slow. Disabling plugins may or may not help this.

In production, use:

    $ OPEN_ISSUE_INTERVAL=1800 bundle exec ruby -Ilib bin/selbot2.rb
        
For use with youtube one needs to create an [API Key](https://developers.google.com/youtube/registering_an_application) and set that as "youtube.conf" environment variable.
