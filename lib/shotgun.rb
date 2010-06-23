require 'rack'

module Shotgun
  autoload :Loader,      'shotgun/loader'
  autoload :SkipFavicon, 'shotgun/favicon'
  autoload :Static,      'shotgun/static'

  def self.new(rackup_file, &block)
    Loader.new(rackup_file, &block)
  end

  def self.enable_copy_on_write
    GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
  end

  def self.preload(files=%w[./config/shotgun.rb ./shotgun.rb])
    files.each do |preload_file|
      if File.exist?(preload_file)
        module_eval File.read(preload_file), preload_file
        return preload_file
      end
    end
  end

  def self.before_fork(&block)
    @before_fork ||= []
    @before_fork << block if block
    @before_fork
  end

  def self.after_fork(&block)
    @after_fork ||= []
    @after_fork << block if block
    @after_fork
  end

  def self.before_fork!
    before_fork.each { |block| block.call }
  end

  def self.after_fork!
    after_fork.each { |block| block.call }
  end
end
