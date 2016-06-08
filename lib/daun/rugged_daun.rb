require 'rugged'
require 'fileutils'
require 'daun/refs_diff'

class RuggedDaun

  def initialize repository_path
    @repository = Rugged::Repository.init_at(repository_path)
  end

  def init(remote_url)
    @repository.remotes.create('origin', remote_url)
  end

  def checkout
    refs_diff = get_refs_diff

    (refs_diff.added(:remotes) + refs_diff.updated(:remotes)).each do |refs|
      checkout_remote_branch refs.to_local_branch
    end

    refs_diff.deleted(:remotes).each do |refs|
      FileUtils.rm_rf File.join(@repository.workdir, 'branches', refs.to_local_branch)
    end

    refs_diff.added(:tags).each do |refs|
      checkout_tag refs.to_tag
    end

    refs_diff.updated(:tags).each do |refs|
      checkout_tag refs.to_tag, true
    end

    refs_diff.deleted(:tags).each do |refs|
      FileUtils.rm_rf File.join(@repository.workdir, 'tags', refs.to_tag)
    end
  end

  private

  def get_refs_diff
    before_fetch = Hash[@repository.refs.collect { |r| [ r.canonical_name, r.target_id ] } ]

    delete_all_remote_branches # Prune is not supported by rugged! Deleting all remote refs and re-fetch
    delete_all_tags
    @repository.remotes['origin'].fetch

    after_fetch = Hash[@repository.refs.collect { |r| [ r.canonical_name, r.target_id ] } ]

    RefsDiff.new(before_fetch, after_fetch)
  end

  def checkout_remote_branch branch
    checkout_target_directory = File.join(@repository.workdir, "branches", branch)
    FileUtils::mkdir_p checkout_target_directory
    @repository.checkout("origin/#{branch}", strategy: :force, target_directory: checkout_target_directory)
  end

  def checkout_tag tag, force = false
    checkout_target_directory = File.join(@repository.workdir, "tags", tag)
    if force and File.exists? checkout_target_directory
      # checkout --force is somehow not working to update the tag
      FileUtils.rm_rf checkout_target_directory
    end
    FileUtils::mkdir_p checkout_target_directory
    @repository.checkout(@repository.tags[tag].target.oid, strategy: :force, target_directory: checkout_target_directory)
  end

  def delete_all_remote_branches
    @repository.branches.each_name(:remote) do |branch|
      @repository.branches.delete branch
    end
  end

  def delete_all_tags
    @repository.tags.each_name do |tag|
      @repository.tags.delete tag
    end
  end
end

class String

  def to_local_branch
    self[/refs\/remotes\/origin\/(.*)/, 1]
  end

  def to_tag
    self[/refs\/tags\/(.*)/, 1]
  end
end