require "../src/redomi"
require "../src/redomi/lib/d3"

server = Redomi::Server.setup(File.join(__DIR__, "public")) do |app|
  app.load_script "/d3.min.js"
  sleep 0.1

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

  Redomi::Lib::D3.new(sq).transition.style({"background-color": "red"})
  sleep 1
  Redomi::Lib::D3.new(sq).transition.style({"background-color": "blue"})
end

server.bind "tcp://127.0.0.1:9090"
server.listen
