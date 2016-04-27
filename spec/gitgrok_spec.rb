require 'spec_helper'
require 'git-opengrok/gitgrok'

describe 'gitgrok' do
  context 'when checking out test repository' do
    before(:context) do
      @tmpdir = Dir.mktmpdir
      bare_repository = create_test_repository File.join(@tmpdir, 'bare-repository')
      @repository = File.join(@tmpdir, 'repository')
      GitGrok.new.init bare_repository, @repository
      GitGrok.new.checkout @repository
    end

    after(:context) do
      FileUtils.rm_rf(@tmpdir)
    end

    it 'checks out master branch' do
      expect(File).to exist("#{@repository}/branches/master")
      expect(File).to exist("#{@repository}/branches/master/foo.txt")
    end

    it 'checks out other branch' do
      expect(File).to exist("#{@repository}/branches/other")
      expect(File).to exist("#{@repository}/branches/other/foo.txt")
    end
  end

  it 'checks out tags'
  it 'deletes branch which have been deleted in remote'
  it 'deletes tag which have been deleted in remote'
  it 'adds new branch which have been added after the first checkout'
  it 'does not check out anything other than the branches and tags to avoid clutter'
end
