require 'spec_helper'
require 'daun/cli'

describe 'daun cli' do
  it "has init and checkout commands" do
    # KLUDGE: Somehow the output from help is not `daun`
    expect { Daun::CLI.start ['help'] }.to output(/rspec checkout/).to_stdout
    expect { Daun::CLI.start ['help'] }.to output(/rspec init/).to_stdout
  end
end
