$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'git-opengrok'
require 'rugged'

def create_test_repository(dir)
  Rugged::Repository.init_at(dir, :bare)
  workdir_path = File.join(dir, 'working_tree')
  workdir_repo = Rugged::Repository.clone_at dir, workdir_path
  FileUtils.cp_r 'spec/repo/.', workdir_path
  index = workdir_repo.index
  index.add_all

  options = {}
  options[:tree] = index.write_tree(workdir_repo)
  index.write

  options[:author] = { :email => "testuser@github.com", :name => 'Test Author', :time => Time.now }
  options[:committer] = { :email => "testuser@github.com", :name => 'Test Author', :time => Time.now }
  options[:message] ||= "Making a commit via Rugged!"
  options[:parents] = workdir_repo.empty? ? [] : [ repo.head.target ].compact
  options[:update_ref] = 'HEAD'
  Rugged::Commit.create workdir_repo, options

  workdir_repo.create_branch 'other'
  workdir_repo.push 'origin', ['refs/heads/master', 'refs/heads/other']
end
