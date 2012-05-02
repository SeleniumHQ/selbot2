IRC bot for the #selenium channel on freenode.

To run the bot locally, try:

    $ bundle install
    $ SELBOT_CHANNEL=#my-test-channel bundle exec ruby -I lib bin/selbot2.rb
    
Note that startup is for unknown reasons quite slow. Disabling plugins may or may not help this.