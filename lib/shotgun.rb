require 'rack'
require 'thread'

class Shotgun
  attr_reader :rackup_file

  def initialize(rackup_file)
    @rackup_file = rackup_file
  end

  @@mutex = Mutex.new

  def call(env)
    @@mutex.synchronize { dup.call!(env) }
  end

  def call!(env)
    @env = env
    @reader, @writer = IO.pipe
    if fork
      proceed_as_parent
    else
      proceed_as_child
    end
  end

  # ==== Stuff that happens in the parent process

  def proceed_as_parent
    @writer.close
    status, headers, body = Marshal.load(@reader)
    @reader.close
    Process.wait
    [status, headers, body]
  end

  # ==== Stuff that happens in the forked child process.

  def inner_app
    config = File.read(rackup_file)
    eval "Rack::Builder.new {( #{config}\n )}.to_app", nil, rackup_file
  end

  def proceed_as_child
    @reader.close
    status, headers, body = inner_app.call(@env)
    Marshal.dump([status, headers.to_hash, slurp(body)], @writer)
    @writer.close
    exit! 0
  end

  def slurp(body)
    return body    if body.respond_to? :to_ary
    return [body]  if body.respond_to? :to_str

    buf = []
    body.each { |part| buf << part }
    buf
  end
end
