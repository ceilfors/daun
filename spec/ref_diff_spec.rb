require 'rspec'
require 'daun/ref_diff'

describe 'ref_diff' do

  [
      {
          :before => {},
          :after => {:'refs/remotes/origin/master' => '1'},
          :expected => ['refs/remotes/origin/master']
      }, {
          :before => {:'refs/remotes/origin/master' => '1'},
          :after => {:'refs/remotes/origin/feature' => '1'},
          :expected => ['refs/remotes/origin/feature']
      }, {
          :before => {:'refs/remotes/origin/master' => '1'},
          :after => {:'refs/remotes/origin/master' => '1', :'refs/remotes/origin/feature' => '1'},
          :expected => ['refs/remotes/origin/feature']
      }, {
          :before => {:'refs/remotes/origin/master' => '1'},
          :after => {:'refs/remotes/origin/master' => '1', :'refs/remotes/origin/feature' => '1', :'refs/remotes/origin/bug' => '1'},
          :expected => ['refs/remotes/origin/bug', 'refs/remotes/origin/feature']
      }
  ].each do |example|
    it 'detects new remotes' do
      ref_diff = RefDiff.new(example[:before], example[:after])

      expect(ref_diff.added).to match_array(example[:expected])
    end
  end

  it 'detects new tags' do
    ref_diff = RefDiff.new({}, {:'refs/tags/1.0' => '1'})

    expect(ref_diff.added).to include('refs/tags/1.0')
  end

  it 'detects updated remotes' do
    pending
    ref_diff = RefDiff.new({:'refs/remotes/origin/master' => '1'},
                           {:'refs/remotes/origin/master' => '2'})

    expect(ref_diff.updated).to include('refs/remotes/origin/master')
  end
end