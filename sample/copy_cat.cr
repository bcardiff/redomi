require "../src/redomi"
require "../src/redomi/lib/jquery"

host = "localhost"
port = 9090

server = Redomi::Server.new(host, port) do |app|
  source = Redomi::UI::TextInput.append_to(app.root)
  target = Redomi::UI::TextInput.append_to(app.root)
  source.on_value_change do |_, value|
    target.value = value
  end
end

server.listen
