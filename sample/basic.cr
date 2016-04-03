require "../src/redomi"

host = "localhost"
port = 9090

server = Redomi::Server.new host, port do |app|
  app.log "App started"

  app.embed_stylesheet %(
    .red { color: red; }
  )

  app.create_element("h1").tap do |h1|
    h1.text_content = "Sample App"
    app.root.append_child h1
  end

  app.create_element("div").tap do |div|
    div.text_content = "Lorem"
    app.root.append_child div
  end

  div2 = app.create_element("div")
  app.root.append_child div2

  sleep 0.5

  div2.text_content = "Ipsum"

  input = app.create_element("input")
  app.root.append_child input

  button = app.create_element("button")
  button.text_content = "Click me"
  app.root.append_child button

  ul = app.create_element("ul")
  first = app.create_element("li")
  first.text_content = "first"

  second = app.create_element("li")
  second.text_content = "second"
  second.class_name = "red"

  ul.append_child first
  ul.append_child second
  app.root.append_child ul

  button.on_click do |btn|
    second.text_content = "changed!"
  end

  sleep 0.5
  first.text_content = "#{second.text_content} copied"

  sleep 0.5
  second.parent.class_name = "red"

  # pp app.query_selector("h1").text
end

puts "Listening on http://#{host}:#{port}"
server.listen
