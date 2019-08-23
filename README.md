# ElasticTabstops

Aligning columns of text in program output can be a harder to do than it's worth.
Fortunately, Nick Gravgaard invented a very nice solution to the problem:
[elastic tabstops](http://nickgravgaard.com/elastic-tabstops/).
In a nutshell, that solution is: move tabstops to fit the text between them, and
force corresponding tabstops on adjacent lines into alignment with each other.

This is a Ruby implementation of the elastic tabstops approach.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'elastic_tabstops'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elastic_tabstops

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at `https://github.com/perlmonger42/elastic_tabstops`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
