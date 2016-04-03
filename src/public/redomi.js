var ws = new WebSocket("ws://" + location.host);
var nodes = {};
assign_node_id = function(dom, id) {
  nodes[id] = dom;
  dom.dataset.remodiNodeId = id;
}
assign_node_id(document.body, 0);
var last_node_id = 0;

ws.onopen = function() {
  ws.send(JSON.stringify({command: "init"}))
};

encode_result = function(result) {
  if (result instanceof Element) {
    if (result.dataset.remodiNodeId === undefined) {
      last_node_id--;
      assign_node_id(result, last_node_id);
    }

    return {__remodi_node_id: parseInt(result.dataset.remodiNodeId)}
  }

  if (result instanceof Array) {
    var mapped = []
    for (var i = 0; i < result.length; i++) {
      mapped.push(encode_result(result[i]));
    }
    return mapped;
  }

  return result;
};

ws.onmessage = function(e) {
  var message = JSON.parse(e.data);
  switch (message.command) {
  case "create":
    var node = document.createElement(message.data.tag);
    assign_node_id(node, message.data.id);
    break;
  case "eval":
    eval(message.data.script);
    break;
  case "eval_sync":
    var result = encode_result(eval(message.data.script));
    ws.send(JSON.stringify({
      command: "response",
      data: {
        response_id: message.data.response_id,
        value: result
      }
    }));
    break;
  case "add_event_listener":
    var node = nodes[message.data.node_id];
    node.addEventListener(message.data.event, function() {
      ws.send(JSON.stringify({
        command: "node_event",
        data: {
          node_id: message.data.node_id,
          event: message.data.event
        }
      }))
    });
  }
};
