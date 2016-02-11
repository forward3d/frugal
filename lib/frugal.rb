$stdout.sync = true
Thread.abort_on_exception = true

require 'logger'
require 'uri'
require 'bundler/setup'
Bundler.require

require_relative 'frugal/helpers/logging'
require_relative 'frugal/helpers/loop'
require_relative 'frugal/helpers/protection'
require_relative 'frugal/check'
