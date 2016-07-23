[![Build Status](https://img.shields.io/circleci/project/ceilfors/daun/master.svg?label=Build Status)](https://circleci.com/gh/ceilfors/daun/tree/master)
[![Code Climate](https://codeclimate.com/github/ceilfors/daun/badges/gpa.svg)](https://codeclimate.com/github/ceilfors/daun)
[![Test Coverage](https://codeclimate.com/github/ceilfors/daun/badges/coverage.svg)](https://codeclimate.com/github/ceilfors/daun/coverage)

# Daun

Daun is a CLI program that will expand git branches and tags to your disk
as directories. Daun will keep the expanded directories in sync whenever there are
new, updated, or deleted tags and branches.

Daun is originally designed to help index your source code in [OpenGrok](https://opengrok.github.io/OpenGrok/).

## Installation

#### Linux

    $ gem install daun

#### Other OS

    $ gem install rugged
    $ gem install daun

Daun uses [`rugged`](https://github.com/libgit2/rugged) gem to talk to git repositories. As of today, this gem
can [be](https://github.com/libgit2/rugged/issues/43)
[problematic](https://github.com/libgit2/rugged/issues/489) 
to be installed in OS other than Linux hence it has been made an optional dependency.
Because of this, you have to be able to install rugged gem manually first before
installing daun. Visit rugged documentation if you have problem installing rugged.

## Usage

    $ daun init [GIT_CLONE_URL] daun-repo
    $ cd daun-repo
    $ daun checkout
    
or

    $ daun init [GIT_CLONE_URL] daun-repo
    $ daun checkout --directory daun-repo

Subsequent calls to `checkout` will update your `daun-repo` directory with the latest
branches and tags:

- Newly created branches and tags will be added in `daun-repo`
- Updated branches and tags will be updated in `daun-repo`
- Deleted branches and tags will be deleted in `daun-repo`

The resulting output of the commands above will look like this in your
disk:

    daun-repo/
        .git/
        branches/
            master/
            feature/foo/
        tags/
            v1.0.0/
        
## Options

Daun options are stored as git config. Hence you will be able to configure your `daun-repo`
just like any git repositories e.g. executing `git config` in your `daun-repo` directory or even
by setting the `global` or `system` git configuration. Visit
[git config official documentation](https://git-scm.com/docs/git-config)
for more information.

The following options are available in daun:


<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Default</th>
    <th>Example</th>
  </tr>
  <tr>
    <th>daun.branch.blacklist</th>
    <td>
    Branches that match the pattern set in this option will not be checked out by daun.
    Multiple patterns are supported by space character. Pattern is matched by using
    <code><a href="http://ruby-doc.org/core-1.9.3/File.html#method-c-fnmatch-3F">File.fnmatch?</a></code> method.
    Daun will by default check out all branches. The example given will blacklist any
    branches that have hotfix/ or release/ prefix.
    </td>
    <td>""</td>
    <td>"hotfix/* release/*"</td>
  </tr>
  <tr>
    <th>daun.tag.blacklist</th>
    <td>
    Tags that match the pattern set in this option will not be checked out by daun.
    Multiple patterns are supported by space character. Pattern is matched by using
    <code><a href="http://ruby-doc.org/core-1.9.3/File.html#method-c-fnmatch-3F">File.fnmatch?</a></code> method.
    Daun will by default check out all tags. The example given will blacklist any
    tags that have staged/ or build/ prefix.
    </td>
    <td>""</td>
    <td>"staged/* build/*"</td>
  </tr>
  <tr>
    <th>daun.tag.limit</th>
    <td>
    This option limits the number of tags being checked out by daun. Daun will
    always keep the latest tags e.g. ordered by date.
    Daun will by default check out all tags without any limit. With the example given,
    daun will only check out the latest 5 tags and ignore the older ones. You can also
    set this value to 0 if you don't want to check out any tags at all.
    </td>
    <td>-1 (unlimited)</td>
    <td>5</td>
</table>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ceilfors/daun. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
