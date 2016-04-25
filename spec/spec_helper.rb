$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'git-opengrok'

def create_bare_repository(dir)
  bare_repository = dir
  Git.init(bare_repository, :bare => true)
  working_tree_path = File.join(dir, 'working_tree')
  working_tree_repo = Git.clone(bare_repository, working_tree_path)
  FileUtils.cp_r 'spec/repo/.', working_tree_path
  working_tree_repo.add(:all => true)
  working_tree_repo.commit('Add spec/repo/.')
  working_tree_repo.push
end
