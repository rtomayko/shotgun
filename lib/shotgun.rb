require 'rack'
require 'rack/utils'
require 'thread'

class Shotgun
  include Rack::Utils
  attr_reader :rackup_file

  def initialize(rackup_file, wrapper=nil)
    @rackup_file = rackup_file
    @wrapper = wrapper || lambda { |inner_app| inner_app }
    enable_copy_on_write
  end

  def call(env)
    dup.call!(env)
  end

  def call!(env)
    @env = env
    @reader, @writer = IO.pipe

    if @child = fork
      proceed_as_parent
    else
      proceed_as_child
    end
  end

  ##
  # Stuff that happens in the parent process

  def proceed_as_parent
    @writer.close
    rand
    result, status, headers = Marshal.load(@reader)
    body = Body.new(@child, @reader)
    case result
    when :ok
      [status, headers, body]
    when :error
      error, backtrace = status, headers
      body.close
      [
        500,
        {'Content-Type'=>'text/html;charset=utf-8'},
        [format_error(error, backtrace)]
      ]
    else
      fail "unexpected response: #{result.inspect}"
    end
  end

  class Body < Struct.new(:pid, :fd)
    def each
      while chunk = fd.read(1024)
        yield chunk
      end
    end

    def close
      fd.close
    ensure
      Process.wait(pid)
    end
  end

  def format_error(error, backtrace)
    "<h1>Boot Error</h1>" +
    "<p>Something went wrong while loading <tt>#{escape_html(rackup_file)}</tt></p>"
    "<h3>#{escape_html(error)}</h3>" +
    "<pre>#{escape_html(backtrace.join("\n"))}</pre>"
  end

  ##
  # Stuff that happens in the child process

  def proceed_as_child
    boom = false
    @reader.close
    app = assemble_app
    status, headers, body = app.call(@env)
    Marshal.dump([:ok, status, headers.to_hash], @writer)
    spec_body(body).each { |chunk| @writer.write(chunk) }
  rescue Object => boom
    Marshal.dump([
      :error,
      "#{boom.class.name}: #{boom.to_s}",
      boom.backtrace
    ], @writer)
  ensure
    @writer.close
    exit! boom ? 1 : 0
  end

  def assemble_app
    @wrapper.call(inner_app)
  end

  def inner_app
    if rackup_file =~ /\.ru$/
      config = File.read(rackup_file)
      eval "Rack::Builder.new {( #{config}\n )}.to_app", nil, rackup_file
    else
      require rackup_file
      if defined? Sinatra::Application
        Sinatra::Application.set :reload, false
        Sinatra::Application.set :logging, false
        Sinatra::Application.set :raise_errors, true
        Sinatra::Application
      else
        Object.const_get(File.basename(rackup_file, '.rb').capitalize)
      end
    end
  end

  def spec_body(body)
    if body.respond_to? :to_str
      [body]
    elsif body.respond_to?(:each)
      body
    else
      fail "body must respond to #each"
    end
  end

  def enable_copy_on_write
    GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
  end

  class SkipFavicon < Struct.new(:app)
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        [404, {
          'Content-Type'  => 'image/png',
          'Cache-Control' => 'public, max-age=100000000000'
        }, []]
      else
        app.call(env)
      end
    end
  end
end
