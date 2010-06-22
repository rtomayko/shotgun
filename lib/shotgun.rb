require 'rack'

module Shotgun
  autoload :Loader, 'shotgun/loader'
  autoload :SkipFavicon, 'shotgun/favicon'

  def self.new(rackup_file, wrapper=nil)
    Loader.new(rackup_file, wrapper)
  end

  def self.enable_copy_on_write
    GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
  end
end
