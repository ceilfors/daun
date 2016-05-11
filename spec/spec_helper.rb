$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'daun'
require 'rugged'

class DaunCliDriver

  def checkout remote_url, destination
    Daun::CLI.start %W{ init #{remote_url} #{destination}}
    Daun::CLI.start %W{ checkout --directory #{destination} }
  end
end

class BareTestRepository

  attr_accessor :path

  def initialize(dir)
    @path = dir
    Rugged::Repository.init_at(dir, :bare)
    @workdir_path = File.join(dir, 'working_tree')
    @workdir_repo = Rugged::Repository.clone_at dir, @workdir_path
    commit "Initial commit."
  end

  def write_file(file_name, content)
    File.write("#{@workdir_path}/#{file_name}", content)
    commit "Write #{file_name}"
    push
  end

  def push
    @workdir_repo.branches.each_name(:local) do |branch|
      @workdir_repo.push 'origin', ["refs/heads/#{branch}"]
    end
    @workdir_repo.tags.each_name do |tag|
      @workdir_repo.push 'origin', ["refs/tags/#{tag}"]
    end
  end

  def create_branch(name)
    @workdir_repo.create_branch name
    @workdir_repo.checkout name
  end

  def create_lightweight_tag(name)
    @workdir_repo.tags.create(name, 'HEAD')
    push
  end

  def create_annotated_tag(name)
    @workdir_repo.tags.create(name, 'HEAD', annotation={:message => 'New annotated tag!'})
    push
  end

  private

  def commit(message)
    index = @workdir_repo.index
    index.add_all
    options = {}
    options[:message] = message
    options[:tree] = index.write_tree(@workdir_repo)
    options[:parents] = @workdir_repo.empty? ? [] : [@workdir_repo.head.target].compact
    options[:update_ref] = 'HEAD'
    index.write
    Rugged::Commit.create @workdir_repo, options
  end

end