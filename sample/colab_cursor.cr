require "../src/redomi"
require "../src/redomi/lib/jquery"

host = "0.0.0.0"
port = 9090
FPS = 30

# shameless track all open applications
$apps = Array(ColabCursorApp).new
$last_usage = ""

# boot each connection as a custom ColabCursorApp
server = Redomi::Server.new(host, port, File.join(__DIR__, "public")) do |app|
  app.load_script "/colab_cursor.js"
  sleep 0.5
  app.eval "trackMouse();"
  app.root["style"] = "cursor: none;"

  ColabCursorApp.new(app)
end

spawn do
  loop do
    $apps.not_nil!.each do |app|
      # request and perform on each client
      spawn do
        app.update_mouse
        app.render_mouses
      end
    end
    $last_usage = `ps -p #{Process.pid} -o %cpu,%mem`
    sleep 1.0/FPS
  end
end

server.listen

class ColabCursorApp
  getter mouse
  getter color

  def initialize(@app : Redomi::App)
    @mouse = {0, 0}
    @color = "##{(rand * 16777215).to_i.to_s(16)}"
    @widgets = [] of Redomi::Node

    @server_usage = Redomi::Node.append_to("div", @app.root)

    $apps << self

    self
  end

  def update_mouse
    # update last known mouse position
    last_mouse = @app.eval_sync("window.lastMouse") as Hash(String, Redomi::Type)
    @mouse = {last_mouse["clientX"] as Int64, last_mouse["clientY"] as Int64}
    pp @mouse
  end

  def render_mouses
    # ensure there are enough widgets for all apps
    ($apps.size - @widgets.size).times do
      @widgets << Redomi::Node.append_to("div", @app.root) do |node|
        node["style"] = "position: absolute;"
        node.text_content = "★"
      end
    end

    # update position of each widget
    @widgets.each_with_index do |w, i|
      app = $apps[i]
      w["style"] = "position: absolute; left: #{app.mouse[0]}px; top: #{app.mouse[1]}px; color: #{app.color};"
    end

    @server_usage.text_content = $last_usage
  end
end
