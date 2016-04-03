var ws = new WebSocket("ws://" + location.host);
var nodes = {};
nodes[0] = $("body")[0];
var last_node_id = 0;

ws.onopen = function() {
  ws.send(JSON.stringify({command: "init"}))
};

decode_args = function(args) {
  for(var i=0; i < args.length; i++) {
    if (args[i].__remodi_node_id) {
      args[i] = nodes[args[i].__remodi_node_id];
    }
  }

  return args;
};

encode_result = function(result) {
  if (result instanceof jQuery) {
    var mapped = [];
    result.each(function() {
      if ($(this).data('__remodi_node_id') === undefined) {
        last_node_id--;
        $(this).data('__remodi_node_id', last_node_id);
        nodes[last_node_id] = this;
      }

      mapped.push({__remodi_node_id: $(this).data('__remodi_node_id')})
    });
    result = mapped;
  }

  return result;
};

ws.onmessage = function(e) {
  var message = JSON.parse(e.data);
  switch (message.command) {
  case "log":
    console.log(message.data);
    break;
  case "create":
    var node = document.createElement(message.data.tag);
    nodes[message.data.id] = node;
    $(node).data('__remodi_node_id', message.data.id);
    break;
  case "find_node":
    var result = encode_result($(message.data.query));
    ws.send(JSON.stringify({
      command: "response",
      data: {
        id: message.data.response_id,
        value: result
      }
    }));
    break;
  case "exec_node":
    var node = $(nodes[message.data.id]);
    node[message.data.method].apply(node, decode_args(message.data.args));
    break;
  case "exec_node_wait_response":
    var node = $(nodes[message.data.id]);
    var result = encode_result(node[message.data.method].apply(node, decode_args(message.data.args)));
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
