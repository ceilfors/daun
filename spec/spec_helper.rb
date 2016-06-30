$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'codeclimate-test-reporter'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new(
      [
          SimpleCov::Formatter::HTMLFormatter,
          CodeClimate::TestReporter::Formatter
      ])
end

require 'daun'
require 'rugged'

RSpec::Matchers.define :checkout_tags do |*expected|
  match do |daun|
    expected.all? { |tag| File.directory? (File.join(daun.tag_dir, tag)) }
  end

  failure_message do |daun|
    "Expected daun to check out tags #{expected} but could not find #{expected - daun.tags}"
  end

  match_when_negated do |daun|
    expected.all? { |tag| not File.directory? (File.join(daun.tag_dir, tag)) }
  end

  failure_message_when_negated do |daun|
    "Expected daun to not checkout tags #{expected} but found #{expected & daun.tags}"
  end
end

RSpec::Matchers.define :checkout_branches do |*expected|
  match do |daun|
    expected.all? { |branch| File.directory? (File.join(daun.branch_dir, branch)) }
  end

  failure_message do |daun|
    "Expected daun to check out branches #{expected} but could not find #{expected - daun.branches}"
  end

  match_when_negated do |daun|
    expected.all? { |branch| not File.directory? (File.join(daun.branch_dir, branch)) }
  end

  failure_message_when_negated do |daun|
    "Expected daun to not checkout branches #{expected} but found #{expected & daun.branches}"
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


  def tag_dir name = nil
    tag_dir  = "#{@last_destination}/tags"
    name ? tag_dir  << "/#{name}" : tag_dir
  end

  def tags
    Rugged::Repository.new(@last_destination).tags.collect { |t| t.canonical_name.to_tag }
  end

  def branch_dir name = nil
    branch_dir = "#{@last_destination}/branches"
    name ? branch_dir << "/#{name}" : branch_dir
  end

  def branches
    Rugged::Repository.new(@last_destination).branches.collect { |b| b.canonical_name.to_local_branch }
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