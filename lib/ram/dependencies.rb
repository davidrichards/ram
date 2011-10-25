# Standard Library Dependencies:
require 'uri'
require 'erb'
require 'zlib'
require 'yaml'
require 'base64'
require 'pathname'
require 'fileutils'

# Include YUI as the default
require 'yui/compressor'

# Try Closure.
begin
  require 'closure-compiler'
rescue LoadError
  Ram.compressors.delete :closure
end

# Try Uglifier.
begin
  require 'uglifier'
rescue LoadError
  Ram.compressors.delete :uglifier
end

# Load initial configuration before the rest of Ram.
Ram.load_configuration(Ram::DEFAULT_CONFIG_PATH, true)

# Ram Core:
require 'ram/uglifier' if Ram.compressors.include? :uglifier
require 'ram/compressor'
require 'ram/packager'

# TODO: See if the helper might be useful in a nanoc environment...
