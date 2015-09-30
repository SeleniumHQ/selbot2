IRC bot for the #selenium channel on freenode.

To run the bot locally, try:

    $ bundle install
    $ SELBOT_CHANNEL=#my-test-channel bundle exec ruby -I lib bin/selbot2.rb
    
Note that startup is for unknown reasons quite slow. Disabling plugins may or may not help this.

In production, use:

    $ OPEN_ISSUE_INTERVAL=1800 bundle exec ruby -Ilib bin/selbot2.rb

For use with youtube one needs to create an [API Key](https://developers.google.com/youtube/registering_an_application) and set that as "youtube.conf" environment variable.
