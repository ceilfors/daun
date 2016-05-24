require 'rspec'
require 'daun/ref_diff'

describe 'ref_diff' do

  it 'detects new remotes' do
    ref_diff = RefDiff.new({}, {:'refs/remotes/origin/master' => '1'})

    expect(ref_diff.added).to include(:'refs/remotes/origin/master' => '1')
  end
end