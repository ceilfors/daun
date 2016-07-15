require 'spec_helper'

describe 'daun' do
  let(:tmpdir) { Dir.mktmpdir }
  let(:bare_repository) { BareTestRepository.new(File.join(tmpdir, 'bare-repository')) }
  let(:destination) { File.join(tmpdir, 'repository') }
  let(:daun) { DaunCliDriver.new }

  after(:each) do
    FileUtils.rm_rf(tmpdir)
  end

  it 'checks out master branch' do
    bare_repository.write_file 'foo.txt', 'branch/master'

    daun.checkout bare_repository.path, destination

    expect(daun).to checkout_branches 'master'
    expect(File.read("#{daun.branch_dir 'master'}/foo.txt")).to match 'branch/master'
  end

  it 'updates master branch with the latest change' do
    bare_repository.write_file 'foo.txt', 'master'
    daun.checkout bare_repository.path, destination

    bare_repository.write_file 'foo.txt', 'updated'
    daun.update destination

    expect(File.read("#{daun.branch_dir 'master'}/foo.txt")).to match 'updated'
  end

  it 'checks out other branch' do
    bare_repository.create_branch 'other'
    bare_repository.write_file 'foo.txt', 'branch/other'

    daun.checkout bare_repository.path, destination

    expect(daun).to checkout_branches 'master', 'other'
    expect(File.read("#{daun.branch_dir 'other'}/foo.txt")).to match 'branch/other'
  end

  it 'deletes branch which have been deleted' do
    bare_repository.create_branch 'other'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_branch 'other'
    daun.update destination

    expect(daun).not_to checkout_branches 'other'
  end

  it 'adds new branch which have been added after the first checkout' do
    daun.checkout bare_repository.path, destination

    bare_repository.create_branch 'other'
    daun.update destination

    expect(daun).to checkout_branches 'master', 'other'
  end

  it 'checks out lightweight tags' do
    bare_repository.write_file 'foo.txt', 'tag/lightweight'
    bare_repository.create_lightweight_tag 'lightweight'

    daun.checkout bare_repository.path, destination

    expect(daun).to checkout_tags 'lightweight'
    expect(File.read("#{daun.tag_dir 'lightweight'}/foo.txt")).to match 'tag/lightweight'
  end

  it 'checks out annotated tags' do
    bare_repository.write_file 'foo.txt', 'tag/annotated'
    bare_repository.create_annotated_tag 'annotated'

    daun.checkout bare_repository.path, destination

    expect(daun).to checkout_tags 'annotated'
    expect(File.read("#{daun.tag_dir 'annotated'}/foo.txt")).to match 'tag/annotated'
  end

  it 'updates lightweight tags with the latest change' do
    bare_repository.write_file 'foo.txt', 'original'
    bare_repository.create_lightweight_tag 'lightweight'
    daun.checkout bare_repository.path, destination

    bare_repository.write_file 'foo.txt', 'updated'
    bare_repository.create_lightweight_tag 'lightweight'
    daun.update destination

    expect(daun).to checkout_tags 'lightweight'
    expect(File.read("#{daun.tag_dir 'lightweight'}/foo.txt")).to match 'updated'
  end

  it 'updates annotated tags with the latest change' do
    bare_repository.write_file 'foo.txt', 'original'
    bare_repository.create_annotated_tag 'annotated'
    daun.checkout bare_repository.path, destination

    bare_repository.write_file 'foo.txt', 'updated'
    bare_repository.create_annotated_tag 'annotated'
    daun.update destination

    expect(daun).to checkout_tags 'annotated'
    expect(File.read("#{daun.tag_dir 'annotated'}/foo.txt")).to match 'updated'
  end

  it 'deletes lightweight tag which have been deleted in remote' do
    bare_repository.create_lightweight_tag 'lightweight'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_tag 'lightweight'
    daun.update destination

    expect(daun).not_to checkout_tags 'lightweight'
  end

  it 'deletes annotated tag which have been deleted in remote' do
    bare_repository.create_annotated_tag 'annotated'
    daun.checkout bare_repository.path, destination

    bare_repository.delete_tag 'annotated'
    daun.update destination

    expect(daun).not_to checkout_tags 'annotated'
  end

  it 'blacklists branch on first checkout' do
    bare_repository.create_branch 'feature/foo'
    bare_repository.create_branch 'feature/bar'
    bare_repository.create_branch 'bugfix/boo'

    daun.checkout bare_repository.path, destination,
                  'branch.blacklist' => 'master bugfix/*'

    expect(daun).to checkout_branches 'feature/foo', 'feature/bar'
    expect(daun).not_to checkout_branches 'master', 'bugfix/boo'
  end

  it 'deletes branches based on the updated blacklist configuration' do
    bare_repository.create_branch 'bugfix/boo'

    daun.checkout bare_repository.path, destination
    daun.config destination, 'branch.blacklist' => 'bugfix/*'

    daun.update destination

    expect(daun).not_to checkout_branches 'bugfix/boo'
  end

  it 'adds branches based on the removed blacklist configuration' do
    bare_repository.create_branch 'bugfix/boo'

    daun.checkout bare_repository.path, destination, 'branch.blacklist' => 'bugfix/*'
    daun.config destination, 'branch.blacklist' => ''
    daun.update destination

    expect(daun).to checkout_branches 'bugfix/boo'
  end

  it 'blacklists tags on first checkout' do
    bare_repository.create_lightweight_tag 'v1'
    bare_repository.create_lightweight_tag 'staged/build1'
    bare_repository.create_annotated_tag 'build/yesterday'

    daun.checkout bare_repository.path, destination,
                  'tag.blacklist' => 'staged/* build/*'

    expect(daun).to checkout_tags 'v1'
    expect(daun).not_to checkout_tags 'staged/build1', 'build/yesterday'
  end

  it 'limits the number of tags being checked out and keep the newest ones' do
    bare_repository.create_lightweight_tags_with_commit_marker 'e', 'd', 'c', 'b', 'a'

    daun.checkout bare_repository.path, destination,
                  'tag.limit' => '2'

    expect(daun).to checkout_tags 'b', 'a'
  end

  it 'deletes tags based on the updated blacklist configuration' do
    bare_repository.create_lightweight_tag 'v1'
    bare_repository.create_lightweight_tag 'staged/build1'
    bare_repository.create_annotated_tag 'build/yesterday'

    daun.checkout bare_repository.path, destination
    daun.config destination, 'tag.blacklist' => 'build/*'
    daun.update destination

    expect(daun).not_to checkout_tags 'build/yesterday'
  end

  it 'adds tags based on the removed blacklist configuration' do
    bare_repository.create_lightweight_tag 'v1'
    bare_repository.create_lightweight_tag 'staged/build1'
    bare_repository.create_annotated_tag 'build/yesterday'

    daun.checkout bare_repository.path, destination, 'tag.blacklist' => 'staged/* build/*'
    daun.config destination, 'tag.blacklist' => 'build/*'
    daun.update destination

    expect(daun).to checkout_tags 'staged/build1'
  end
end
