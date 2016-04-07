require "../src/redomi"
host = "localhost"
port = 9090

server = Redomi::Server.new(host, port) do |app|
  app.embed_stylesheet %(
    .blue-sq {
      background-color: blue;
      position: absolute;
      top: 10px;
      left: 10px;
      width: 50px;
      height: 50px;
    }
  )

  sq = app.create_element("div")
  sq.class_name = "blue-sq"
  app.root.append_child sq

  sleep 0.1
  sq["style"] = "width: 100px; height: 25px; background-color: red; transition: width 2s, height 2s, background-color 2s, transform 2s;"

  sleep 3
  sq["style"] = "transition: width 2s, height 2s, background-color 2s, transform 2s;"
end

server.listen
