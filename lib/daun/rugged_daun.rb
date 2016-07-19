require 'rugged'
require 'fileutils'

module Daun
  ##
  # Implementation of daun using Rugged library.
  class RuggedDaun
    def initialize(repository_path)
      @repository = Rugged::Repository.init_at(repository_path)
      @logger = Logging.logger[self]
    end

    def init(remote_url)
      @repository.remotes.create('origin', remote_url)
      @repository.config['daun.tag.blacklist'] = ''
      @repository.config['daun.tag.limit'] = '-1'
      @repository.config['daun.branch.blacklist'] = ''
    end

    def checkout
      @logger.info 'Fetching git repository..'
      refs_diff = fetch_refs

      refs_diff.added(:remotes).each do |refs|
        @logger.info "Adding #{refs}.."
        checkout_remote_branch refs.to_local_branch, get_checkout_directory(refs)
      end

      refs_diff.updated(:remotes).each do |refs|
        @logger.info "Updating #{refs}.."
        checkout_remote_branch refs.to_local_branch, get_checkout_directory(refs)
      end

      refs_diff.deleted(:remotes).each do |refs|
        @logger.info "Deleting #{refs}.."
        FileUtils.rm_rf get_checkout_directory refs
      end

      refs_diff.added(:tags).each do |refs|
        @logger.info "Adding #{refs}.."
        checkout_tag refs.to_tag, get_checkout_directory(refs)
      end

      refs_diff.updated(:tags).each do |refs|
        @logger.info "Updating #{refs}.."
        checkout_tag(refs.to_tag, get_checkout_directory(refs), force: true)
      end

      refs_diff.deleted(:tags).each do |refs|
        @logger.info "Deleting #{refs}.."
        FileUtils.rm_rf get_checkout_directory refs
      end

      @logger.info "Finished checking out #{@repository.remotes['origin'].url} to #{@repository.workdir}"
    end

    private

    def fetch_refs
      before_fetch = Hash[@repository.refs.collect { |r| [r.name, r.target_id] }]

      # Prune is not supported by rugged! Deleting all remote refs and re-fetch
      delete_all_remote_branches
      delete_all_tags
      @repository.remotes['origin'].fetch

      delete_all_remote_branches @repository.config['daun.branch.blacklist'].split
      delete_all_tags @repository.config['daun.tag.blacklist'].split
      if @repository.config['daun.tag.limit'].to_i > -1
        keep_new_tags @repository.config['daun.tag.limit'].to_i
      end

      after_fetch = Hash[@repository.refs.collect { |r| [r.name, r.target_id] }]

      Daun::RefsDiff.new(before_fetch, after_fetch)
    end

    def checkout_remote_branch(branch, target_dir)
      FileUtils.mkdir_p target_dir
      @repository.checkout("origin/#{branch}",
                           strategy: :force, target_directory: target_dir)
    end

    def checkout_tag(tag, target_dir, options = { force: false })
      if File.exist?(target_dir) && options[:force]
        # checkout --force is somehow not working to update the tag
        FileUtils.rm_rf target_dir
      end
      FileUtils.mkdir_p target_dir
      @repository.checkout(@repository.tags[tag].target.oid,
                           strategy: :force, target_directory: target_dir)
    end

    def delete_all_remote_branches(patterns = ['*'])
      patterns.each do |pattern|
        @repository.branches.each_name(:remote) do |branch|
          if File.fnmatch? "origin/#{pattern}", branch
            @repository.branches.delete branch
          end
        end
      end
    end

    def delete_all_tags(patterns = ['*'])
      patterns.each do |pattern|
        @repository.tags.each_name do |tag|
          @repository.tags.delete tag if File.fnmatch? pattern, tag
        end
      end
    end

    def keep_new_tags(limit)
      @repository.tags.sort_by { |tag| tag.target.time }
        .take(@repository.tags.count - limit)
        .each { |t| @repository.tags.delete t.name }
    end

    def get_checkout_directory(refs)
      if refs.start_with? 'refs/remotes'
        File.join(@repository.workdir, 'branches', refs.to_local_branch)
      elsif refs.start_with? 'refs/tags'
        File.join(@repository.workdir, 'tags', refs.to_tag)
      else
        raise "#{refs} is unsupported"
      end
    end
  end
end

# Add convenience methods to grab information from git refs
class String
  def to_local_branch
    self[%r{refs/remotes/origin/(.*)}, 1]
  end

  def to_tag
    self[%r{refs/tags/(.*)}, 1]
  end
end
