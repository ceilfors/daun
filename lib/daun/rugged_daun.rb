require 'rugged'
require 'fileutils'
require 'daun/refs_diff'

class RuggedDaun

  def initialize repository_path
    @repository = Rugged::Repository.init_at(repository_path)
  end

  def init(remote_url)
    @repository.remotes.create('origin', remote_url)
    @repository.config['daun.tag.blacklist'] = ''
    @repository.config['daun.tag.limit'] = '-1'
    @repository.config['daun.branch.blacklist'] = ''
  end

  def checkout
    refs_diff = get_refs_diff

    (refs_diff.added(:remotes) + refs_diff.updated(:remotes)).each do |refs|
      checkout_remote_branch refs.to_local_branch, get_checkout_directory(refs)
    end

    refs_diff.deleted(:remotes).each do |refs|
      FileUtils.rm_rf get_checkout_directory refs
    end

    refs_diff.added(:tags).each do |refs|
      checkout_tag refs.to_tag, get_checkout_directory(refs)
    end

    refs_diff.updated(:tags).each do |refs|
      checkout_tag(refs.to_tag, get_checkout_directory(refs), :force => true)
    end

    refs_diff.deleted(:tags).each do |refs|
      FileUtils.rm_rf get_checkout_directory refs
    end
  end

  private

  def get_refs_diff
    # TODO Use r.name? What is the difference with canonical_name?
    before_fetch = Hash[@repository.refs.collect { |r| [ r.canonical_name, r.target_id ] } ]

    # Prune is not supported by rugged! Deleting all remote refs and re-fetch
    delete_all_remote_branches
    delete_all_tags
    @repository.remotes['origin'].fetch

    # Delete blacklisted references
    @repository.config['daun.branch.blacklist'].split.each do |pattern|
      @repository.branches.each_name(:remote) do |branch|
        if File.fnmatch? "origin/#{pattern}", branch
          @repository.branches.delete branch
        end
      end
    end
    @repository.config['daun.tag.blacklist'].split.each do |tag_pattern|
      @repository.tags.each_name(tag_pattern) do |tag|
        @repository.tags.delete tag
      end
    end
    if @repository.config['daun.tag.limit'].to_i > -1
      @repository.tags.sort_by { |tag| tag.target.time}
          .take(@repository.tags.count - @repository.config['daun.tag.limit'].to_i)
          .each { |t| @repository.tags.delete t.name }
    end

    after_fetch = Hash[@repository.refs.collect { |r| [r.canonical_name, r.target_id] }]

    RefsDiff.new(before_fetch, after_fetch)
  end

  def checkout_remote_branch branch, target_dir
    FileUtils::mkdir_p target_dir
    @repository.checkout("origin/#{branch}", strategy: :force, target_directory: target_dir)
  end

  def checkout_tag(tag, target_dir, options = {:force => false})
    if options[:force] and File.exists? target_dir
      # checkout --force is somehow not working to update the tag
      FileUtils.rm_rf target_dir
    end
    FileUtils::mkdir_p target_dir
    @repository.checkout(@repository.tags[tag].target.oid, strategy: :force, target_directory: target_dir)
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

  def get_checkout_directory refs
    if refs.start_with? 'refs/remotes'
      File.join(@repository.workdir, "branches", refs.to_local_branch)
    elsif refs.start_with? 'refs/tags'
      File.join(@repository.workdir, "tags", refs.to_tag)
    else
      raise "#{refs} is unsupported"
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