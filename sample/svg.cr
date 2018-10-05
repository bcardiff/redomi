require "../src/redomi"
require "../src/redomi/lib/jquery"

server = Redomi::Server.setup do |app|
  slider = Redomi::UI::SliderInput.append_to(app.root)
  slider.value = 20

  svg = Redomi::SVG::SVG.append_to(app.root)

  circle = Redomi::SVG::Circle.append_to(svg) do |circle|
    circle.cx = 50
    circle.cy = 50
    circle.r = slider.value
  end

  rect = Redomi::SVG::Rect.append_to(svg) do |rect|
    rect.width = 10
    rect.height = 70
    rect.x = circle.cx + circle.r
  end

  slider.on_value_change do |_, value|
    circle.r = slider.value
    rect.x = circle.cx + circle.r
  end
end

server.bind "tcp://127.0.0.1:9090"
server.listen
