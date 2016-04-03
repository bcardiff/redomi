require "../src/redomi"

host = "localhost"
port = 9090

server = Redomi::Server.new host, port do |app|
  app.log "App started"

  app.embed_stylesheet %(
    .red { color: red; }
  )

  app.create_element("h1").tap do |h1|
    h1.text = "Sample App"
    app.root.append h1
  end

  app.create_element("div").tap do |div|
    div.text = "Lorem"
    app.root.append div
  end

  div2 = app.create_element("div")
  app.root.append div2

  sleep 0.5

  div2.text = "Ipsum"

  input = app.create_element("input")
  app.root.append input

  button = app.create_element("button")
  button.text = "Click me"
  app.root.append button

  ul = app.create_element("ul")
  first = app.create_element("li")
  first.text = "first"

  second = app.create_element("li")
  second.text = "second"
  second.add_class "red"

  ul.append first
  ul.append second
  app.root.append ul

  button.on_click do |btn|
    second.text = "changed!"
  end

  sleep 0.5
  first.text = "#{second.text} copied"

  sleep 0.5
  second.parent.add_class "red"

  pp app.find_node("h1").text
end

puts "Listening on http://#{host}:#{port}"
server.listen
