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

  it "checks out master branch successfully" do
    bare_repository.write_file "foo.txt", "branch/master"

    daun.checkout bare_repository.path, destination

    expect(File).to exist("#{destination}/branches/master")
    expect(File).to exist("#{destination}/branches/master/foo.txt")
    expect(File.read("#{destination}/branches/master/foo.txt")).to match "branch/master"
  end

  it 'checks out other branch successfully' do
    bare_repository.create_branch 'other'
    bare_repository.write_file "foo.txt", "branch/other"

    daun.checkout bare_repository.path, destination

    expect(File).to exist("#{destination}/branches/other")
    expect(File).to exist("#{destination}/branches/other/foo.txt")
    expect(File.read("#{destination}/branches/other/foo.txt")).to match "branch/other"
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

  it 'updates master branch with the latest change'

  it 'deletes branch which have been deleted' do
    pending("updates master branch")
    bare_repository.create_branch 'other'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_branch 'other'
    daun.update destination

    expect(File).not_to exist("#{destination}/branches/other")
  end

  it 'deletes tag which have been deleted in remote'
  it 'adds new branch which have been added after the first checkout'
  it 'does not check out anything other than the branches and tags to avoid clutter'
  it 'does not check out branches when it is configured not do so'
  it 'does not check out tags when it is configured not do so'
  it 'filters branches check out according to the configuration'
  it 'filters tags check out according to the configuration'
end
