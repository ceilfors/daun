require 'spec_helper'
require 'git-opengrok/cli'

describe 'cli' do
  it "should print help when help subcommand is used" do
    expect { GitOpenGrok::CLI.start %w{ help } }.to output(/Commands:/).to_stdout
  end

  it "should not print to stdout when subcommand is unrecognized" do
    expect { GitOpenGrok::CLI.start %w{ foo } }.not_to output(/Commands:/).to_stdout
  end

  it "checks out master branch successfully" do
    Dir.mktmpdir do |dir|
      # Preparation
      bare_repository = File.join(dir, 'bare-repository')
      Git.init(bare_repository, :bare => true)
      working_tree_path = File.join(dir, 'working_tree')
      working_tree_repo = Git.clone(bare_repository, working_tree_path)
      FileUtils.cp_r 'spec/repo/.', working_tree_path
      working_tree_repo.add(:all => true)
      working_tree_repo.commit('Add repo')
      working_tree_repo.push

      # Execute
      destination = File.join(dir, 'repository')
      expect { GitOpenGrok::CLI.start %W{ init #{destination} #{bare_repository}} }.not_to output(/Could not find command/).to_stderr
      expect { GitOpenGrok::CLI.start %W{ checkout -C #{destination} } }.not_to output(/Could not find command/).to_stderr

      # Verification
      expect(File).to exist("#{destination}/branches/master")
      expect(File).to exist("#{destination}/branches/master/foo.txt")
    end
  end
end
