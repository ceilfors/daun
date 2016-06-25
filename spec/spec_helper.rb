$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'daun'
require 'rugged'

RSpec::Matchers.define :checkout_tags do |*expected|
  match do |daun|
    daun.tags.sort == expected.sort
  end

  failure_message do |daun|
    "Expected daun to check out tags #{expected.sort} but found #{daun.tags.sort}"
  end
end

class DaunCliDriver

  def checkout remote_url, destination, config = {}
    @last_destination = destination
    Daun::CLI.start %W{ init #{remote_url} #{destination}}

    config(destination, config)

    Daun::CLI.start %W{ checkout --directory #{destination} }
  end

  def config repository, config = {}
    repo = Rugged::Repository.new(repository)
    config.each_pair do | key, value |
      repo.config["daun.#{key}"] = value
    end
  end

  def update repository
    Daun::CLI.start %W{ checkout --directory #{repository} }
  end

  def tags
    self.inspect # KLUDGE: Ruby 1.9 bug! Tested in ruby 2.1 and this line is not required
    (Dir.entries("#{@last_destination}/tags") - ['.'] - ['..'])
  end
end

class BareTestRepository

  attr_accessor :path

  AUTHOR = {:email => 'daun@github.com', :name => 'daun-tester'}

  def initialize(dir)
    @path = dir
    Rugged::Repository.init_at(dir, :bare)
    @workdir_path = File.join(dir, 'working_tree')
    @workdir_repo = Rugged::Repository.clone_at dir, @workdir_path
    commit "Initial commit."
    push
  end

  def write_file(file_name, content)
    File.write("#{@workdir_path}/#{file_name}", content)
    commit "Write #{file_name}"
    push
  end

  def create_branch(name)
    @workdir_repo.create_branch name
    @workdir_repo.checkout name
    push
  end

  def delete_branch(name)
    @workdir_repo.checkout 'master'
    @workdir_repo.branches.delete name
    @workdir_repo.branches.delete "origin/#{name}"
    @workdir_repo.remotes['origin'].push([":refs/heads/#{name}"])
  end

  def delete_tag(name)
    @workdir_repo.tags.delete(name)
    @workdir_repo.remotes['origin'].push([":refs/tags/#{name}"])
  end

  def create_lightweight_tags_with_commit_marker(*names)
    names.each.with_index do |name, i|
      commit 'Commit market that is useful for tag ordering by date', Time.now + i * 60
      create_lightweight_tag name
    end
  end

  def create_lightweight_tag(name)
    if @workdir_repo.tags[name]
      delete_tag name
    end
    @workdir_repo.tags.create(name, 'HEAD')
    push
  end

  def create_annotated_tag(name)
    if @workdir_repo.tags[name]
      delete_tag name
    end
    @workdir_repo.tags.create(name, 'HEAD', annotation={:tagger => AUTHOR, :message => 'New annotated tag!'})
    push
  end

  private

  def commit(message, time=Time.now)
    AUTHOR[:time] = time
    index = @workdir_repo.index
    index.add_all
    options = {}
    options[:message] = message
    options[:committer] = AUTHOR
    options[:author] = AUTHOR
    options[:tree] = index.write_tree(@workdir_repo)
    options[:parents] = @workdir_repo.empty? ? [] : [@workdir_repo.head.target].compact
    options[:update_ref] = 'HEAD'
    index.write
    Rugged::Commit.create @workdir_repo, options
  end

  def push
    @workdir_repo.branches.each_name(:local) do |branch|
      @workdir_repo.push 'origin', ["refs/heads/#{branch}"]
    end
    @workdir_repo.tags.each_name do |tag|
      @workdir_repo.push 'origin', ["refs/tags/#{tag}"]
    end
  end
end