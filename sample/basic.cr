require "../src/redomi"

host = "localhost"
port = 9090

server = Redomi::Server.new host, port do |app|
  app.log "App started"

  h1 = Redomi::Node.new(app.root, "h1")
  h1.text = "Sample App"

  div1 = Redomi::Node.new(app.root, "div")
  div2 = Redomi::Node.new(app.root, "div")
  div1.text = "Lorem"

  sleep 0.5

  div2.text = "Ipsum"

  input = Redomi::Node.new(app.root, "input")
  button = Redomi::Node.new(app.root, "button")
  button.text = "Click me"

  ul = Redomi::Node.new(app.root, "ul")

  first = Redomi::Node.new(ul, "li")
  first.text = "first"

  second = Redomi::Node.new(ul, "li")
  second.text = "second"
  second.add_class "red"

  button.on_click do |btn|
    second.text = "changed!"
  end

  sleep 0.5
  first.text = "#{second.text} copied"
end

puts "Listening on http://#{host}:#{port}"
server.listen
