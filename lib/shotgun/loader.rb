require 'rack/utils'
require 'thread'

module Shotgun
  # Rack app that forks, loads the rackup config in the child process,
  # processes a single request, and exits. The response is communicated over
  # a unidirectional pipe.
  class Loader
    include Rack::Utils
    attr_reader :rackup_file

    def initialize(rackup_file, &block)
      @rackup_file = rackup_file
      @config = block || Proc.new { }
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env
      @reader, @writer = IO.pipe

      Shotgun.before_fork!

      if @child = fork
        proceed_as_parent
      else
        Shotgun.after_fork!
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
      "<p>Something went wrong while loading <tt>#{escape_html(rackup_file)}</tt></p>" +
      "<h3>#{escape_html(error)}</h3>" +
      "<pre>#{escape_html(backtrace.join("\n"))}</pre>"
    end

    ##
    # Stuff that happens in the child process

    def proceed_as_child
      boom = false
      @reader.close
      status, headers, body = assemble_app.call(@env)
      Marshal.dump([:ok, status, headers.to_hash], @writer)
      spec_body(body).each { |chunk| @writer.write(chunk) }
      body.close if body.respond_to?(:close)
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
      config = @config
      inner_app = self.inner_app
      Rack::Builder.new {
        instance_eval(&config)
        run inner_app
      }.to_app
    end

    def inner_app
      if rackup_file =~ /\.ru$/
        config = File.read(rackup_file)
        eval "Rack::Builder.new {( #{config}\n )}.to_app", nil, rackup_file
      else
        require File.expand_path(rackup_file)
        if defined? Sinatra::Application
          Sinatra::Application.set :reload, false
          Sinatra::Application.set :logging, false
          Sinatra::Application.set :raise_errors, true
          Sinatra::Application
        else
          Object.const_get(camel_case(File.basename(rackup_file, '.rb')))
        end
      end
    end

    def camel_case(string)
      string.split("_").map { |part| part.capitalize }.join
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
  end
end
