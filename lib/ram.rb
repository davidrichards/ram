$LOAD_PATH.push File.expand_path(File.dirname(__FILE__))

# @Ram@ is the central namespace for all Ram classes, and provides access
# to all of the configuration options.
module Ram

  VERSION               = File.open(File.expand_path('../../VERSION', __FILE__), 'r').read

  ROOT                  = File.expand_path(File.dirname(__FILE__) + '/..')

  ASSET_ROOT            = '.' unless defined?(ASSET_ROOT)

  DEFAULT_PUBLIC_ROOT   = 'output' unless defined?(PUBLIC_ROOT)

  DEFAULT_CONFIG_PATH   = File.join(ASSET_ROOT, 'assets.yml')

  DEFAULT_PACKAGE_PATH  = "assets"

  DEFAULT_JST_SCRIPT    = File.join(ROOT, 'lib/ram/jst.js')

  DEFAULT_JST_COMPILER  = "template"

  DEFAULT_JST_NAMESPACE = "window.JST"

  COMPRESSORS           = [:yui, :closure, :uglifier]

  DEFAULT_COMPRESSOR    = :yui

  # Extension matchers for JavaScript and JST, which need to be disambiguated.
  JS_EXTENSION          = /\.js\Z/
  DEFAULT_JST_EXTENSION = "jst"

  # Ram raises a @PackageNotFound@ exception when a non-existent package is
  # requested by a browser -- rendering a 404.
  class PackageNotFound < NameError; end

  # Ram raises a MissingConfiguration exception when you try to load the
  # configuration of an assets.yml file that doesn't exist, or are missing 
  # a piece of required configuration.
  class MissingConfiguration < NameError; end

  # Ram raises an OutputNotWritable exception if the output directory for
  # cached packages is locked.
  class OutputNotWritable < StandardError; end

  # Ram raises a DeprecationError if you try to use an outdated feature.
  class DeprecationError < StandardError; end

  class << self
    attr_reader   :configuration, :template_function, :template_namespace,
                  :embed_assets, :package_assets, :compress_assets, :gzip_assets,
                  :package_path, :mhtml_enabled, :include_jst_script, :config_path,
                  :javascript_compressor, :compressor_options, :css_compressor_options,
                  :template_extension, :template_extension_matcher, :allow_debugging,
                  :public_root
    attr_accessor :compressors
  end

  # The minimal required configuration.
  @configuration  = {}
  @public_root    = DEFAULT_PUBLIC_ROOT
  @package_path   = DEFAULT_PACKAGE_PATH
  @compressors    = COMPRESSORS

  # Load the complete asset configuration from the specified @config_path@.
  # If we're loading softly, don't let missing configuration error out.
  def self.load_configuration(config_path, soft=false)
    exists = config_path && File.exists?(config_path)
    return false if soft && !exists
    raise MissingConfiguration, "could not find the \"#{config_path}\" configuration file" unless exists
    conf = YAML.load(ERB.new(File.read(config_path)).result)

    @config_path            = config_path
    @configuration          = symbolize_keys(conf)
    @package_path           = conf[:package_path] || DEFAULT_PACKAGE_PATH
    @embed_assets           = conf[:embed_assets] || conf[:embed_images]
    @compress_assets        = !(conf[:compress_assets] == false)
    @gzip_assets            = !(conf[:gzip_assets] == false)
    @allow_debugging        = !(conf[:allow_debugging] == false)
    @mhtml_enabled          = @embed_assets && @embed_assets != "datauri"
    @compressor_options     = symbolize_keys(conf[:compressor_options] || {})
    @css_compressor_options = symbolize_keys(conf[:css_compressor_options] || {})
    set_javascript_compressor(conf[:javascript_compressor])
    set_package_assets(conf[:package_assets])
    set_template_function(conf[:template_function])
    set_template_namespace(conf[:template_namespace])
    set_template_extension(conf[:template_extension])
    set_public_root(conf[:public_root]) if conf[:public_root]
    symbolize_keys(conf[:stylesheets]) if conf[:stylesheets]
    symbolize_keys(conf[:javascripts]) if conf[:javascripts]
    check_for_deprecations
    self
  end

  # Force a reload by resetting the Packager and reloading the configuration.
  # In development, this will be called as a before_filter before every request.
  def self.reload!
    Thread.current[:ram_packager] = nil
    load_configuration(@config_path)
  end

  # Keep a global (thread-local) reference to a @Ram::Packager@, to avoid
  # recomputing asset lists unnecessarily.
  def self.packager
    Thread.current[:ram_packager] ||= Packager.new
  end

  # Generate the base filename for a version of a given package.
  def self.filename(package, extension, suffix=nil)
    suffix_part  = suffix ? "-#{suffix}" : ''
    "#{package}#{suffix_part}.#{extension}"
  end

  # Generates the server-absolute URL to an asset package.
  def self.asset_url(package, extension, suffix=nil, mtime=nil)
    timestamp = mtime ? "?#{mtime.to_i}" : ''
    "/#{package_path}/#{filename(package, extension, suffix)}#{timestamp}"
  end

  # Convenience method for packaging up Ram, using the default options.
  def self.package!(options={})
    options = {
      :config_path    => Ram::DEFAULT_CONFIG_PATH,
      :output_folder  => nil,
      :base_url       => nil,
      :public_root    => nil,
      :force          => false
    }.merge(options)
    load_configuration(options[:config_path])
    set_public_root(options[:public_root]) if options[:public_root]
    packager.force         = options[:force]
    packager.package_names = options[:package_names]
    packager.precache_all(options[:output_folder], options[:base_url])
  end

  private

  # Allows command-line definition of `PUBLIC_ROOT`
  def self.set_public_root(public_root=nil)
    @public_root = public_root if public_root
  end

  # Ensure that the JavaScript compressor is a valid choice.
  def self.set_javascript_compressor(value)
    value = value && value.to_sym
    @javascript_compressor = compressors.include?(value) ? value : DEFAULT_COMPRESSOR
  end

  # Turn asset packaging on or off, depending on configuration and environment.
  def self.set_package_assets(value)
    package_env     = 'production'
    @package_assets = value == true || value.nil? ? package_env :
                      value == 'always'           ? true : false
  end

  # Assign the JST template function, unless explicitly turned off.
  def self.set_template_function(value)
    @template_function = value == true || value.nil? ? DEFAULT_JST_COMPILER :
                         value == false              ? '' : value
    @include_jst_script = @template_function == DEFAULT_JST_COMPILER
  end

  # Set the root JS object in which to stash all compiled JST.
  def self.set_template_namespace(value)
    @template_namespace = value == true || value.nil? ? DEFAULT_JST_NAMESPACE : value.to_s
  end

  # Set the extension for JS templates.
  def self.set_template_extension(value)
    @template_extension = (value == true || value.nil? ? DEFAULT_JST_EXTENSION : value.to_s).gsub(/\A\.?(.*)\Z/, '\1')
    @template_extension_matcher = /\.#{Regexp.escape(@template_extension)}\Z/
  end

  # The YUI Compressor requires Java > 1.4, and Closure requires Java > 1.6.
  def self.check_java_version
    return true if @checked_java_version
    java = @compressor_options[:java] || 'java'
    @css_compressor_options[:java] ||= java if @compressor_options[:java]
    version = (`#{java} -version 2>&1`)[/\d+\.\d+/]
    disable_compression if !version ||
      (@javascript_compressor == :closure && version < '1.6') ||
      (@javascript_compressor == :yui && version < '1.4')
    @checked_java_version = true
  end

  # If we don't have a working Java VM, then disable asset compression and
  # complain loudly.
  def self.disable_compression
    @compress_assets = false
    warn("Asset compression disabled -- Java unavailable.")
  end

  # Ram 0.5+ no longer supports separate template packages.
  def self.check_for_deprecations
    if @configuration[:templates]
      raise DeprecationError, "Ram 0.5+ no longer supports separate packages for templates.\nPlease fold your templates into the appropriate 'javascripts' package instead."
    end
  end

  def self.warn(message)
    message = "Ram Warning: #{message}"
    $stderr.puts message
  end

  # Clone of active_support's symbolize_keys, so that we don't have to depend
  # on active_support in any fashion. Converts a hash's keys to all symbols.
  def self.symbolize_keys(hash)
    hash.keys.each do |key|
      hash[(key.to_sym rescue key) || key] = hash.delete(key)
    end
    hash
  end

end

require 'ram/dependencies'
