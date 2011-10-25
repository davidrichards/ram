Gem::Specification.new do |s|
  s.name      = 'ram'
  s.version   = '0.0.1'         # Keep version in sync with ram.rb
  s.date      = '2011-10-25'

  s.homepage    = "http://fleetventures.com/"
  s.summary     = "Asset Packaging"
  s.description = <<-EOS
    Ram is an asset packaging library for any type of web project.  It was 
    originalyl adapted from the excellent Jammit gem, but without any Rails
    dependencies or tie ins.   This provides both the CSS and JavaScript 
    concatenation and compression that you'd expect, as well as YUI Compressor 
    and Closure Compiler compatibility, ahead-of-time gzipping, built-in 
    JavaScript template support, and optional Data-URI / MHTML image embedding.
  EOS

  s.authors           = ['David Richards']
  s.email             = 'david@fleetventures.com'
  s.rubyforge_project = 'ram'

  s.require_paths     = ['lib']
  s.executables       = ['ram']

  s.extra_rdoc_files  = ['README.md']
  s.rdoc_options      << '--title'    << 'Ram' <<
                         '--exclude'  << 'test' <<
                         '--main'     << 'README.md' <<
                         '--all'

  s.add_dependency 'yui-compressor',    ['>= 0.9.3']

  s.files = Dir['lib/**/*', 'bin/*', 'ram.gemspec', 'LICENSE', 'README.md']
end
