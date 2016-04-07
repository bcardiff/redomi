require "../src/redomi"
require "../src/redomi/lib/jquery"

host = "localhost"
port = 9090

server = Redomi::Server.new(host, port) do |app|
  slider = Redomi::UI::SliderInput.append_to(app.root)
  slider.value = 20

  svg = Redomi::SVG::SVG.append_to(app.root)
  circle = Redomi::SVG::Circle.append_to(svg)
  circle["cx"] = "50"
  circle["cy"] = "50"
  circle["r"] = slider.value.to_s

  slider.on_value_change do |_, value|
    circle["r"] = slider.value.to_s
  end
end

server.listen
