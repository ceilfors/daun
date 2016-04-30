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
      expect(File.read("#{@repository}/branches/master/foo.txt")).to match "branch/master"
    end

    it 'checks out other branch' do
      expect(File).to exist("#{@repository}/branches/other")
      expect(File).to exist("#{@repository}/branches/other/foo.txt")
      expect(File.read("#{@repository}/branches/other/foo.txt")).to match "branch/other"
    end

    it 'checks out lightweight tags' do
      expect(File).to exist("#{@repository}/tags/lightweight")
      expect(File).to exist("#{@repository}/tags/lightweight/foo.txt")
      expect(File.read("#{@repository}/tags/lightweight/foo.txt")).to match "tag/lightweight"
    end
  end

  it 'checks out annotated tags'
  it 'deletes branch which have been deleted in remote'
  it 'deletes tag which have been deleted in remote'
  it 'adds new branch which have been added after the first checkout'
  it 'does not check out anything other than the branches and tags to avoid clutter'
  it 'does not check out branches when it is configured not do so'
  it 'does not check out tags when it is configured not do so'
end
