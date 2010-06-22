class BigResponse
  def call(env)
    [200, {'Content-Type'=>'text/html'}, self]
  end

  def each
    yield "<pre>"
    1024.times do
      yield(('.' * 1023) + "\n")
    end
    yield "</pre>"
  end
end

run BigResponse.new
