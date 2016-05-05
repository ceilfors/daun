require 'spec_helper'
require 'daun/cli'

describe 'daun cli' do
  it "has init and checkout commands" do
    # KLUDGE: Somehow the output from help is not `daun`
    expect { Daun::CLI.start ['help'] }.to output(/rspec checkout/).to_stdout
    expect { Daun::CLI.start ['help'] }.to output(/rspec init/).to_stdout
  end

  it "checks out master branch successfully" do
    Dir.mktmpdir do |dir|
      # Preparation
      bare_repository = File.join(dir, 'bare-repository')
      create_test_repository bare_repository

      # Execute
      destination = File.join(dir, 'repository')
      Daun::CLI.start %W{ init #{bare_repository} #{destination}}
      Daun::CLI.start %W{ checkout --directory #{destination} }

      # Verification
      expect(File).to exist("#{destination}/branches/master")
      expect(File).to exist("#{destination}/branches/master/foo.txt")
    end
  end
end
