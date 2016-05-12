require "http/server"

ws_handler = HTTP::WebSocketHandler.new do |ws|
  puts "new websocket"

  ws.on_message do |message|
    puts "sent from client"
    puts message

    ws.send "dolor sit amet"
  end
end

server = HTTP::Server.new "0.0.0.0", 8080, [ws_handler] do |context|
  context.response.headers["Content-Type"] = "text/html"
  context.response.print <<-HTML
    <html>
      <body>
        <script type="text/javascript">
          var ws = new WebSocket("ws://" + location.host);

          ws.onopen = function() {
            console.log("ws connected");
            ws.send("lorem ipsum");
          };

          ws.onmessage = function(e) {
            console.log("sent from server:", e);
          };
        </script>
      </body>
    </html>
  HTML
end

puts "Listening on http://0.0.0.0:8080"
server.listen
