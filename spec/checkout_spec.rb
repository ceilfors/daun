require 'spec_helper'
require 'git-opengrok/checkout'
require 'tmpdir'

describe 'checkout' do
  it 'checks out branches to the destination directory' do
    Dir.mktmpdir do |dir|
      destination = File.join(dir, 'repository')
      checkout = GitOpenGrok::Checkout.new(destination, 'file:///some-bare-repository')
      checkout.apply

      expect(File).to exist("#{destination}/branches/master")
    end
  end
end
