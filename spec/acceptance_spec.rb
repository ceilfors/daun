require 'spec_helper'
require 'daun/cli'
require 'fileutils'
require 'tmpdir'

describe 'acceptance' do

  let(:tmpdir) { Dir.mktmpdir }
  let(:bare_repository) { BareTestRepository.new(File.join(tmpdir, 'bare-repository')) }
  let(:destination) { File.join(tmpdir, 'repository') }

  after(:each) do
    FileUtils.rm_rf(tmpdir)
  end

  it "checks out master branch successfully" do
    bare_repository.write_file "branch/master"

    Daun::CLI.start %W{ init #{bare_repository.path} #{destination}}
    Daun::CLI.start %W{ checkout --directory #{destination} }

    expect(File).to exist("#{destination}/branches/master")
    expect(File).to exist("#{destination}/branches/master/foo.txt")
    expect(File.read("#{destination}/branches/master/foo.txt")).to match "branch/master"
  end
end
