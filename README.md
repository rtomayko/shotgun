# Shotgun

This is an automatic reloading version of the rackup command that's shipped with
Rack. It can be used as an alternative to the complex reloading logic provided
by web frameworks or in environments that don't support application reloading.

The shotgun command starts one of Rack's supported servers (e.g., mongrel, thin,
webrick) and listens for requests but does not load any part of the actual
application. Each time a request is received, it forks, loads the application in
the child process, processes the request, and exits the child process. The
result is clean, application-wide reloading of all source files and templates on
each request.

## Installation

```bash
$ gem install shotgun
```

## Usage

### Starting a server with a rackup file

```bash
$ shotgun config.ru
```

### Using Thin and starting on port 6000 instead of 9393 (default)

```bash
$ shotgun --server=thin --port=6000 config.ru
```

### Running Sinatra apps

```bash
$ shotgun hello.rb
```

See `shotgun --help` for more advanced usage.

## Links

* [Shotgun](http://github.com/rtomayko/shotgun)
* [Rack](http://rack.rubyforge.org/)
* [Sinatra](http://www.sinatrarb.com/)

The reloading system in Ian Bicking's webware framework served as inspiration
for the approach taken in Shotgun. Ian lays down the pros and cons of this
approach in the following article: http://ianbicking.org/docs/Webware_reload.html