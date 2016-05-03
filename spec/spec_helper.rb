$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'git-opengrok'
require 'rugged'

def create_test_repository(dir)
  Rugged::Repository.init_at(dir, :bare)
  workdir_path = File.join(dir, 'working_tree')
  workdir_repo = Rugged::Repository.clone_at dir, workdir_path
  FileUtils.cp_r 'spec/repo/.', workdir_path
  index = workdir_repo.index
  File.write("#{workdir_path}/foo.txt", 'branch/master')
  index.add_all

  options = {}
  options[:tree] = index.write_tree(workdir_repo)
  index.write

  options[:message] = "Add spec/repo/."
  options[:parents] = workdir_repo.empty? ? [] : [workdir_repo.head.target].compact
  options[:update_ref] = 'HEAD'
  Rugged::Commit.create workdir_repo, options
  workdir_repo.push 'origin', ['refs/heads/master']

  File.write("#{workdir_path}/foo.txt", 'tag/lightweight')
  index.add_all
  options[:message] = "Write tag/lightweight"
  options[:tree] = index.write_tree(workdir_repo)
  index.write
  options[:parents] = workdir_repo.empty? ? [] : [workdir_repo.head.target].compact
  commit_hash = Rugged::Commit.create workdir_repo, options
  workdir_repo.tags.create('lightweight', commit_hash)
  workdir_repo.push 'origin', ['refs/tags/lightweight']

  File.write("#{workdir_path}/foo.txt", 'tag/annotated')
  index.add_all
  options[:message] = "Write tag/annotated"
  options[:tree] = index.write_tree(workdir_repo)
  index.write
  options[:parents] = workdir_repo.empty? ? [] : [workdir_repo.head.target].compact
  commit_hash = Rugged::Commit.create workdir_repo, options
  workdir_repo.tags.create('annotated', commit_hash, annotation={:message => 'tag message'})
  workdir_repo.push 'origin', ['refs/tags/annotated']

  workdir_repo.create_branch 'other'
  workdir_repo.checkout 'other'
  File.write("#{workdir_path}/foo.txt", 'branch/other')
  index.add_all
  options[:message] = "Write branch/other"
  options[:tree] = index.write_tree(workdir_repo)
  index.write
  options[:parents] = workdir_repo.empty? ? [] : [workdir_repo.head.target].compact
  Rugged::Commit.create workdir_repo, options
  workdir_repo.push 'origin', ['refs/heads/other']

  dir
end
