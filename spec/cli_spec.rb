require 'spec_helper'
require 'git-opengrok/cli'

describe 'cli' do
  it "should print help when help subcommand is used" do
    expect { GitOpenGrok::CLI.start %w{ help } }.to output(/Commands:/).to_stdout
  end

  it "should not print to stdout when subcommand is unrecognized" do
    expect { GitOpenGrok::CLI.start %w{ foo } }.not_to output(/Commands:/).to_stdout
  end

  it 'checks out master branch'
end
