require 'spec_helper'

describe 'rugged_daun' do
  let(:tmpdir) { Dir.mktmpdir }
  let(:bare_repository) { BareTestRepository.new(File.join(tmpdir, 'bare-repository')) }
  let(:destination) { File.join(tmpdir, 'repository') }

  after(:each) do
    FileUtils.rm_rf(tmpdir)
  end

  it 'limits tags when the number of git tags are more than the limit' do
    bare_repository.create_lightweight_tags_with_commit_marker 'e', 'd', 'c', 'b', 'a'

    daun = Daun::RuggedDaun.new(destination)
    daun.init(bare_repository.path)
    daun.config['daun.tag.limit'] = '2'
    daun.checkout

    tags_dir = File.join(destination, 'tags')
    expect(File).to be_directory("#{tags_dir}/b")
    expect(File).to be_directory("#{tags_dir}/a")
    expect(File).to_not exist("#{tags_dir}/e")
    expect(File).to_not exist("#{tags_dir}/d")
    expect(File).to_not exist("#{tags_dir}/c")
  end

  it 'does not try to limit tags when the number of real tags are lower than the configured limit' do
    bare_repository.create_lightweight_tags_with_commit_marker '1'

    daun = Daun::RuggedDaun.new(destination)
    daun.init(bare_repository.path)
    daun.config['daun.tag.limit'] = '10000'
    daun.checkout

    tags_dir = File.join(destination, 'tags')
    expect(File).to be_directory("#{tags_dir}/1")
  end
end
