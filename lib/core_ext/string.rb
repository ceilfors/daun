# Add convenience methods to grab information from git refs
class String
  # Grabs branch name from git remote refs.
  def to_local_branch
    self[%r{refs/remotes/origin/(.*)}, 1]
  end

  # Grabs tag name from git tag refs.
  def to_tag
    self[%r{refs/tags/(.*)}, 1]
  end
end
