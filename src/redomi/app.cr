require "json"

module Redomi
  class App
    getter root : Node

    def initialize(@ws : HTTP::WebSocket, &@on_init : App ->)
      @nodes = {} of Int32 => Node
      @node_events = {} of {Int32, String} => (Node -> Void)
      @last_node_id = 0
      @last_response_id = 0
      @pending_responses = {} of Int32 => Channel(JSON::Any)

      @ws.on_message do |message|
        json = JSON.parse(message)
        case json["command"].as_s
        when "init"
          spawn do
            init
          end
        when "node_event"
          data = json["data"]
          node = @nodes[data["node_id"].as_i]
          spawn do
            @node_events[{node.id, data["event"].as_s}].call(node)
          end
        when "response"
          data = json["data"]
          @pending_responses[data["response_id"].as_i].send(data["value"])
        end
      end

      @root = Node.new(0)
      @root.app = self
    end

    def init
      @on_init.call self
    end

    def log(message)
      eval "console.log(%s)", message
    end

    def load_script(path)
      node = create_element("script")
      node["type"] = "text/javascript"
      node["src"] = path
      query_selector("head").append_child(node)
      node
    end

    def embed_stylesheet(css_code)
      node = create_element("style")
      node["type"] = "text/css"
      node.text_content = css_code
      query_selector("head").append_child(node)
      node
    end

    def create_element(tag, t : Node.class = Node)
      @last_node_id += 1

      send_command "create" do |json|
        json.field "tag", tag
        json.field "namespace", t.namespace if t.namespace
        json.field "id", @last_node_id
      end

      node = t.new(@last_node_id)
      node.app = self
      node.init
      node
    end

    def query_selector(query)
      eval_sync("document.querySelector(%s)", query).as(Node)
    end

    # :nodoc:
    def register_node(node)
      @nodes[node.id] = node
    end

    def node_by_id(id)
      node = @nodes[id]?
      # if the id is known, it was assigned by the client
      # client assigned id are negatives
      # server assigned id are positives (App#create_element)
      # 0 is the root element that the client decided which to be. Usually <body>
      unless node
        @nodes[id] = node = Node.new(id)
        node.app = self
      end
      node
    end

    private def encode_param(arg)
      if arg.is_a?(Node)
        {"__redomi_node_id": arg.id}
      else
        arg
      end
    end

    private def encode_params(args : Enumerable)
      args.map { |arg| encode_param(arg) }.to_a
    end

    def eval(command)
      send_command "eval" do |json|
        json.field "script", command
      end
    end

    def eval(command, *arg : Redomi::Type)
      send_command "eval" do |json|
        json.field "script", build_client_script(command, *arg)
      end
    end

    def eval_sync(command)
      send_command_sync "eval_sync" do |json|
        json.field "script", command
      end
    end

    def eval_sync(command, *arg : Redomi::Type)
      send_command_sync "eval_sync" do |json|
        json.field "script", build_client_script(command, *arg)
      end
    end

    private def build_client_script(command, *args : Redomi::Type)
      args_client = args.map do |arg|
        case arg
        when Node
          "nodes[%i]" % arg.id
        else
          arg.to_json
        end
      end

      command % args_client
    end

    def add_event_listener(node, event, proc : Node -> Void)
      @node_events[{node.id, event}] = proc
      send_command "add_event_listener" do |json|
        json.field "node_id", node.id
        json.field "event", event
      end
    end

    private def send_command(command)
      @ws.send(String.build do |io|
        json = JSON::Builder.new(io)
        json.start_document

        json.object do
          json.field "command", command
          json.field "data" do
            json.object do
              yield json
            end
          end
        end

        json.end_document
      end)
    end

    private def send_command_sync(command)
      @last_response_id += 1
      response_id = @last_response_id

      ch = Channel(JSON::Any).new
      @pending_responses[response_id] = ch

      send_command command do |json|
        json.field "response_id", response_id
        yield json
      end

      response = ch.receive.raw.to_redomi(self)
      @pending_responses.delete(response_id)

      response
    end
  end
end
