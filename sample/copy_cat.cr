require "../src/redomi"
require "../src/redomi/lib/jquery"

server = Redomi::Server.setup do |app|
  source = Redomi::UI::TextInput.append_to(app.root)
  target = Redomi::UI::TextInput.append_to(app.root)
  source.on_value_change do |_, value|
    target.value = value
  end
end

server.bind "tcp://127.0.0.1:9090"
server.listen
