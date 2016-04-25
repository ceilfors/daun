require 'spec_helper'
require 'git-opengrok/gitgrok'

describe 'gitgrok' do
  it 'checks out master branch' do
    Dir.mktmpdir do |dir|
      # Preparation
      bare_repository = File.join(dir, 'bare-repository')
      create_bare_repository bare_repository

      # Execute
      destination = File.join(dir, 'repository')
      GitGrok.new.init bare_repository, destination
      GitGrok.new.checkout destination

      # Verification
      expect(File).to exist("#{destination}/branches/master")
      expect(File).to exist("#{destination}/branches/master/foo.txt")
    end
  end

  it 'checks out other branches'
  it 'checks out tags'
  it 'deletes branch which have been deleted in remote'
  it 'deletes tag which have been deleted in remote'
  it 'adds new branch which have been added after the first checkout'
  it 'does not check out anything other than the branches and tags to avoid clutter'
end
