# Gort

Gort parses robots.txt files and checks if a given URL is allowed to be accessed by a given user agent. It implements RFC 9309.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add gort

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install gort

## Usage

Gort doesn't implement any network operations. You can fetch robots.txt using any method you like.

```ruby
robots_txt = Gort.parse(robots_txt_content)
```

`robots_txt_content` should be a string containing the content of a robots.txt file. It's expected to be a UTF-8 encoded string but Gort will try to convert it to UTF-8 if it's not, it will try detecting the encoding using the `rchardet` gem.

After parsing the robots.txt file, you can check if a given path (and query) is allowed to be accessed by a given user agent:

```ruby
robots_txt.allowed?('MyBot', '/path/to/resource')
robots_txt.allowed?('MyBot', '/path/to/resource?query=string')
robots_txt.disallowed?('MyBot', '/private/path/to/resource')
```

You can also insect contents of the robots.txt file:

```ruby
robots_txt.rules # => Array of Gort::Rule, Gort::Group, or Gort::InvalidLine objects
```

See docs for more information on what you can do with those objects.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
