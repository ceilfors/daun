require 'spec_helper'
require 'daun/cli'
require 'fileutils'
require 'tmpdir'

describe 'daun' do

  let(:tmpdir) { Dir.mktmpdir }
  let(:bare_repository) { BareTestRepository.new(File.join(tmpdir, 'bare-repository')) }
  let(:destination) { File.join(tmpdir, 'repository') }
  let(:daun) { DaunCliDriver.new }

  after(:each) do
    FileUtils.rm_rf(tmpdir)
  end

  it 'checks out master branch' do
    bare_repository.write_file "foo.txt", "branch/master"

    daun.checkout bare_repository.path, destination

    expect(File).to exist("#{destination}/branches/master")
    expect(File).to exist("#{destination}/branches/master/foo.txt")
    expect(File.read("#{destination}/branches/master/foo.txt")).to match "branch/master"
  end

  it 'updates master branch with the latest change' do
    bare_repository.write_file "foo.txt", "master"
    daun.checkout bare_repository.path, destination

    bare_repository.write_file "foo.txt", "updated"
    daun.update destination

    expect(File.read("#{destination}/branches/master/foo.txt")).to match "updated"
  end

  it 'checks out other branch' do
    bare_repository.create_branch 'other'
    bare_repository.write_file "foo.txt", "branch/other"

    daun.checkout bare_repository.path, destination

    expect(File).to exist("#{destination}/branches/other")
    expect(File).to exist("#{destination}/branches/other/foo.txt")
    expect(File.read("#{destination}/branches/other/foo.txt")).to match "branch/other"
  end

  it 'deletes branch which have been deleted' do
    bare_repository.create_branch 'other'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_branch 'other'
    daun.update destination

    expect(File).not_to exist("#{destination}/branches/other")
  end

  it 'adds new branch which have been added after the first checkout' do
    daun.checkout bare_repository.path, destination

    bare_repository.create_branch 'other'
    daun.update destination

    expect(File).to exist("#{destination}/branches/other")
  end

  it 'checks out lightweight tags' do
    bare_repository.write_file "foo.txt", "tag/lightweight"
    bare_repository.create_lightweight_tag 'lightweight'

    daun.checkout bare_repository.path, destination

    expect(File).to exist("#{destination}/tags/lightweight")
    expect(File).to exist("#{destination}/tags/lightweight/foo.txt")
    expect(File.read("#{destination}/tags/lightweight/foo.txt")).to match "tag/lightweight"
  end

  it 'checks out annotated tags' do
    bare_repository.write_file "foo.txt", "tag/annotated"
    bare_repository.create_annotated_tag 'annotated'

    daun.checkout bare_repository.path, destination

    expect(File).to exist("#{destination}/tags/annotated")
    expect(File).to exist("#{destination}/tags/annotated/foo.txt")
    expect(File.read("#{destination}/tags/annotated/foo.txt")).to match "tag/annotated"
  end

  it 'updates lightweight tags with the latest change' do
    bare_repository.write_file "foo.txt", "original"
    bare_repository.create_lightweight_tag 'lightweight'
    daun.checkout bare_repository.path, destination

    bare_repository.write_file "foo.txt", "updated"
    bare_repository.create_lightweight_tag 'lightweight'
    daun.update destination

    expect(File).to exist("#{destination}/tags/lightweight")
    expect(File).to exist("#{destination}/tags/lightweight/foo.txt")
    expect(File.read("#{destination}/tags/lightweight/foo.txt")).to match "updated"
  end

  it 'updates annotated tags with the latest change' do
    bare_repository.write_file "foo.txt", "original"
    bare_repository.create_annotated_tag 'annotated'
    daun.checkout bare_repository.path, destination

    bare_repository.write_file "foo.txt", "updated"
    bare_repository.create_annotated_tag 'annotated'
    daun.update destination

    expect(File).to exist("#{destination}/tags/annotated")
    expect(File).to exist("#{destination}/tags/annotated/foo.txt")
    expect(File.read("#{destination}/tags/annotated/foo.txt")).to match "updated"
  end

  it 'deletes lightweight tag which have been deleted in remote' do
    bare_repository.create_lightweight_tag 'lightweight'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_tag 'lightweight'
    daun.update destination

    expect(File).not_to exist("#{destination}/tags/lightweight")
  end

  it 'deletes annotated tag which have been deleted in remote' do
    bare_repository.create_annotated_tag 'annotated'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_tag 'annotated'
    daun.update destination

    expect(File).not_to exist("#{destination}/tags/annotated")
  end

  it 'filters branches check out according to the configuration' do
    bare_repository.create_branch 'feature/foo'
    bare_repository.create_branch 'feature/bar'
    bare_repository.create_branch 'bugfix/boo'

    daun.checkout bare_repository.path, destination, {
      'refs.filter' => 'refs/remotes/origin/feature/.*'
    }

    expect(File).to exist("#{destination}/branches/feature/foo")
    expect(File).to exist("#{destination}/branches/feature/bar")

    expect(File).not_to exist("#{destination}/branches/master")
    expect(File).not_to exist("#{destination}/branches/bugfix/boo")
  end

  it 'deletes branches based on the updated filter configuration' do
    bare_repository.create_branch 'bugfix/boo'

    daun.checkout bare_repository.path, destination
    daun.config destination, {
        'refs.filter' => 'refs/remotes/origin/feature/.*'
    }
    daun.update destination

    expect(File).not_to exist("#{destination}/branches/master")
    expect(File).not_to exist("#{destination}/branches/bugfix/boo")
  end

  it 'adds branches based on the updated filter configuration' do
    bare_repository.create_branch 'bugfix/boo'

    daun.checkout bare_repository.path, destination, {
        'refs.filter' => 'refs/remotes/origin/feature/.*'
    }
    daun.config destination, {
        'refs.filter' => 'refs/remotes/origin/bugfix/.*'
    }
    daun.update destination

    expect(File).not_to exist("#{destination}/branches/master")
    expect(File).to exist("#{destination}/branches/bugfix/boo")
  end

  it 'blacklists tags' do
    bare_repository.create_lightweight_tag 'v1'
    bare_repository.create_lightweight_tag 'staged/build1'
    bare_repository.create_annotated_tag 'build/yesterday'

    daun.checkout bare_repository.path, destination,
        'tag.blacklist' => 'staged/* build/*'

    expect(File).not_to exist("#{destination}/tags/build")
    expect(File).not_to exist("#{destination}/tags/staged")
    expect(File).to exist("#{destination}/tags/v1")
  end

  it 'limits the number of tags being checked out and ordered by date'
  it 'checks out branch and tags that is nested in a directory'
  it 'does not check out branches when it is configured not do so'
  it 'does not check out tags when it is configured not do so'
  it 'filters tags check out according to the configuration'
end
