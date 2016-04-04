require "../src/redomi"
require "../src/redomi/lib/jquery"

host = "localhost"
port = 9090

server = Redomi::Server.new(host, port, File.join(__DIR__, "public")) do |app|
  app.load_script "/jquery-2.2.1.min.js"

  app.log "App started"

  app.embed_stylesheet %(
    .red { color: red; }
    .b-yellow { background-color: yellow; }
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
  jq_second = Redomi::Lib::JQuery.new(second)
  second.text_content = "second"
  second.class_name = "red"

  ul.append_child first
  ul.append_child second
  app.root.append_child ul

  button.on_click do |btn|
    second.text_content = "changed!"
    sleep 0.5
    jq_second.text = "#{jq_second.text} again!"
    sleep 0.5
    jq_second.html = "with <b>html()</b>"
  end

  sleep 0.5
  first.text_content = "#{second.text_content} copied"

  sleep 0.5
  second.parent.class_name = "red"
  jq_second.parent.add_class("b-yellow")

  # pp app.query_selector("h1").text
end

puts "Listening on http://#{host}:#{port}"
server.listen
