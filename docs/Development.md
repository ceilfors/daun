# Building gem

    $ bundle
    $ bundle exec rake

# Install and release


To install this gem onto your local machine:

    bundle exec rake install

To release a new version:

1. Update the version number in `version.rb`
2. Run `bundle exec rake release`
   
    This step will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# Mac OS X

rugged 0.24.0 can't be used easily somehow. Try to follow these steps
to install rugged successfully:

1. brew install cmake 
2. brew install libgit2
3. bundle config build.rugged --use-system-libraries
4. bundle install

For the latest update of rugged, please read [its documentation](https://github.com/libgit2/rugged).

One of the problem is shown below:

      Referenced from: /Users/ceilfors/.rvm/gems/ruby-1.9.3-p551/gems/rugged-0.24.0/lib/rugged/rugged.bundle
      Reason: Incompatible library version: rugged.bundle requires version 8.0.0 or later, but libiconv.2.dylib provides version 7.0.0 - /Users/ceilfors/.rvm/gems/ruby-1.9.3-p551/gems/rugged-0.24.0/lib/rugged/rugged.bundle
        from /Users/ceilfors/.rvm/rubies/ruby-1.9.3-p551/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:69:in `require'
        from /Users/ceilfors/.rvm/gems/ruby-1.9.3-p551/gems/rugged-0.24.0/lib/rugged.rb:5:in `rescue in <top (required)>'
        from /Users/ceilfors/.rvm/gems/ruby-1.9.3-p551/gems/rugged-0.24.0/lib/rugged.rb:1:in `<top (required)>'
        ...

 