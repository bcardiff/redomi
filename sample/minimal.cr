require "../src/redomi"
include Redomi
host = "localhost"
port = 9090

server = Server.new(host, port) do |app|
  app.log "App started"

  Node.append_to("h1", app.root) do |node|
    node.text_content = "Title"
  end

  Node.append_to("ul", app.root) do |ul|
    Node.append_to("li", ul) do |li|
      li.text_content = "first item"
    end

    Node.append_to("li", ul) do |li|
      li.text_content = "second item"
    end
  end
end

server.listen
