# Sqrl::Check

A test suite to check the spec conformance of SQRL implementations. Currently only partial server tests are implemented.

For a gentle introduction to SQRL, try http://sqrl.pl  For All the gritty technical detail, https://www.grc.com/sqrl/sqrl.htm

## Installation

Not currently released to RubyGems

To run directly, simply clone the repo.

In a larger project, add this line to your application's Gemfile:

    gem "sqrl_check", :github => 'JustinLove/sqrl_check', :branch => 'master'

And then execute:

    $ bundle

## Usage

Run the test suite directly with `rake test`. The default configuration assumes local testing, checking `http://localhost:3000', and assumes a self-signed certificate if TLS is used. This can be controlled either through environment variables or rake parameters

    rake test["https://sqrl-test.herokuapp.com/",true]
    SQRL_CHECK_URL="https://sqrl-test.herokuapp.com/" SQRL_CHECK_SIGNED_CERT=true rake test

Individual test files can be run directly, but must use ENV form

    SQRL_CHECK_URL="https://sqrl-test.herokuapp.com/" bundle exec ruby lib/sqrl/check/server/integrity_test.rb

The specified url is expected to be a publicly accessible HTML page where a valid nonced SQRL url can be found.

### Programatic Usage

    require 'sqrl/check/server'
    
    report = SQRL::Check::Server.run
    p report.failures, report.errors, report.results

`report` is a Minitest reporter, currently a child of `Minitest::StatisticsReporter`

## Account Creation

The tests will create numerous anonymous identities. If you wish to tag identities for cleanup, the test client will identiy it's agent as `SQRL/1 SQRL::Check/version` for SQRL requests and `SQRL::Check/version` for plain HTTP requests. Feedback is welcome on possible SQRL options etc. that could be used to tag test accounts.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

