# veslo

_veslo (ru)_ -- paddle

veslo is a command-line interface for the [Noah](https://github.com/lusis/Noah) server.

The first version implement getting and saving configuration entities:

    veslo configurations get config.yml

The default output is to STDOUT, so you can pipe it wherever you want, for example:

    veslo configurations get config.yml > current_production_config.yml

The put command accepts two arguments: the config name on the server and the local config file to upload (or STDIN) _TODO_

    veslo configurations put config.yml my_new_config.yml

The server to use is either configured via the **~/.noah/veslo.rb** file, or passed in the **-s** paramater.

# Contributing to veslo
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

# Copyright

Copyright (c) 2011 Dimitri Krassovski / Wix.com. See LICENSE.txt for
further details.

