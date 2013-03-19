# airbrake-mongo

Sync Airbrake errors to a local mongo database for searching.

#Requirements

* MongoDB `brew update && brew install mongo`
* Ruby 1.9 and Bundler

#Setup

    $ git clone git://github.com/zhm/airbrake-mongo.git airbrake-mongo
    $ cd airbrake-mongo
    $ bundle --path .bundle

# Usage

    $ ruby airbrake_sync.rb sync -a YOUR_ACCOUNT -t YOUR_TOKEN -p PROJECT_ID
