require "../src/redomi"
require "../src/redomi/lib/jquery"

FPS = 30

# boot each connection as a custom ColabCursorApp
server = Redomi::Server.setup(File.join(__DIR__, "public")) do |app|
  app.load_script "/colab_cursor.js"
  sleep 0.5
  app.eval "trackMouse();"
  app.root["style"] = "cursor: none;"

  ColabCursorApp.new(app)
end

spawn do
  loop do
    ColabCursorApp.apps.each do |app|
      # request and perform on each client
      spawn do
        app.update_mouse
        app.render_mice
      end
    end
    ColabCursorApp.last_usage = `ps -p #{Process.pid} -o %cpu,%mem`
    sleep 1.0/FPS
  end
end

server.bind "tcp://0.0.0.0:9090"
server.listen

class ColabCursorApp
  class_getter apps = Array(ColabCursorApp).new
  class_property last_usage = ""

  getter mouse
  getter color
  @server_usage : Redomi::Node

  def initialize(@app : Redomi::App)
    @mouse = {0, 0}
    @color = "##{(rand * 16777215).to_i.to_s(16)}"
    @widgets = [] of Redomi::Node

    @server_usage = Redomi::Node.append_to("div", @app.root)

    ColabCursorApp.apps << self

    self
  end

  def update_mouse
    # update last known mouse position
    last_mouse = @app.eval_sync("window.lastMouse").as(Hash(String, Redomi::Type))
    @mouse = {last_mouse["clientX"].as(Int64), last_mouse["clientY"].as(Int64)}
    pp @mouse
  end

  def render_mice
    # ensure there are enough widgets for all apps
    (ColabCursorApp.apps.size - @widgets.size).times do
      @widgets << Redomi::Node.append_to("div", @app.root) do |node|
        node["style"] = "position: absolute;"
        node.text_content = "★"
      end
    end

    # update position of each widget
    @widgets.each_with_index do |w, i|
      app = ColabCursorApp.apps[i]
      w["style"] = "position: absolute; left: #{app.mouse[0]}px; top: #{app.mouse[1]}px; color: #{app.color};"
    end

    @server_usage.text_content = ColabCursorApp.last_usage
  end
end
