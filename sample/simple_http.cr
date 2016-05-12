require "http/server"

handlers = [
  HTTP::StaticFileHandler.new(File.join(__DIR__, "public")),
]

server = HTTP::Server.new "0.0.0.0", 8080, handlers do |context|
  context.response.headers["Content-Type"] = "text/plain"
  context.response.print("Hello world!")
end

puts "Listening on http://0.0.0.0:8080"
server.listen
