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
    it 'detects new references' do
      ref_diff = RefDiff.new(example[:before], example[:after])

      expect(ref_diff.added).to match_array(example[:expected])
    end
  end

  [
      {
          :before => {},
          :after => {:'refs/remotes/origin/master' => '1'},
          :type => :tags,
          :expected => []
      }, {
          :before => {},
          :after => {:'refs/tags/1.0' => '1', :'refs/remotes/origin/master' => 1},
          :type => :tags,
          :expected => ['refs/tags/1.0']
      }, {
          :before => {},
          :after => {:'refs/tags/1.0' => '1', :'refs/remotes/origin/master' => 1},
          :type => :remotes,
          :expected => ['refs/remotes/origin/master']
      }
  ].each do |example|
    it 'filters references by type' do
      ref_diff = RefDiff.new(example[:before], example[:after])

      expect(ref_diff.added example[:type]).to match_array(example[:expected])
    end
  end

  it 'detects updated references' do
    ref_diff = RefDiff.new({:'refs/remotes/origin/master' => '1'},
                           {:'refs/remotes/origin/master' => '2'})

    expect(ref_diff.updated).to match_array(['refs/remotes/origin/master'])
  end
end