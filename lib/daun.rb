require 'logging'
require 'daun/version'
require 'daun/rugged_daun'
require 'daun/refs_diff'

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info
