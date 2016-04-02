var ws = new WebSocket("ws://" + location.host);
var nodes = {};
nodes[0] = $("body")[0];

ws.onopen = function() {
  ws.send(JSON.stringify({command: "init"}))
};

ws.onmessage = function(e) {
  var message = JSON.parse(e.data);
  switch (message.command) {
  case "log":
    console.log(message.data);
    break;
  case "create":
    var node = document.createElement(message.data.tag);
    $(nodes[message.data.parent_id]).append(node);
    nodes[message.data.id] = node;
    break;
  case "exec_node":
    var node = $(nodes[message.data.id]);
    node[message.data.method].apply(node, message.data.args);
    break;
  case "exec_node_wait_response":
    var node = $(nodes[message.data.id]);
    var result = node[message.data.method].apply(node, message.data.args);
    ws.send(JSON.stringify({
      command: "response",
      data: {
        id: message.data.response_id,
        value: result
      }
    }));
  case "on_node_event":
    var node = $(nodes[message.data.id]);
    node.on(message.data.event, function() {
      ws.send(JSON.stringify({
        command: "node_event",
        data: {
          id: message.data.id,
          event: message.data.event
        }
      }))
    });
  }
};
