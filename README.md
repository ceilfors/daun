# Daun

Daun is a CLI program that will expand your git branches and tags to your disk
as directories. Daun will keep the expanded directories in sync whenever there are
new, updated, or deleted tags and branches.

## Installation

    $ gem install daun

## Usage

    $ daun init https://github.com/ceilfors/daun.git daun-repo
    $ cd daun-repo
    $ daun checkout
    
or

    $ daun init https://github.com/ceilfors/daun.git daun-repo
    $ daun checkout --directory daun-repo

Subsequent calls to `checkout` will update your `daun-repo` directory with the latest
tags and branches.

The example output of the commands above:

    daun-repo/
        .git/
        branches/
            master/
            feature/foo/
        tags/
            v1.0.0/
        
## Options

Daun options are stored as git config. Hence you will be able to configure your `daun-repo` directory
just like any git repositories e.g. executing `$ git config` in your `daun-repo` directory or even
by setting the `global` or `system` git configuration.

* daun.branch.blacklist

    Default: ""  
    Example: "hotfix/* release/*"

    Branches that match the pattern set in this option will not be checked out by daun.
    Multiple patterns are supported by space character. Pattern is matched by using
    [File.fnmatch?](http://ruby-doc.org/core-1.9.3/File.html#method-c-fnmatch-3F) method.
    The example above will blacklist any tags that have hotfix/ or release/ prefix.

* daun.tag.blacklist
  
    Default: ""  
    Example: "staged/* build/*"
  
    Tags that match the pattern set in this option will not be checked out by daun.
    Multiple patterns are supported by space character. Pattern is matched by using
    [File.fnmatch?](http://ruby-doc.org/core-1.9.3/File.html#method-c-fnmatch-3F) method.
    The example above will blacklist any tags that have staged/ or build/ prefix.
  
* daun.tag.limit

    default: -1 (unlimited)  
    Example: 5

    This option limits the number of tags being checked out by daun. Daun will
    always keep the latest tags. With the example above, daun will only checkout
    the latest 5 tags and ignore the older ones.

## Development - OSX

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

1. brew install cmake
2. brew install libgit2
3. bundle config build.rugged --use-system-libraries
4. bundle install
5. bundle exec rake

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ceilfors/daun. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

