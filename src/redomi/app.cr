require "json"

module Redomi
  class App
    getter root : Node

    def initialize(@ws : HTTP::WebSocket, &@on_init : App ->)
      @nodes = {} of Int32 => Node
      @node_events = {} of {Int32, String} => (Node -> Void)
      @last_node_id = 0
      @last_response_id = 0
      @pending_responses = {} of Int32 => Channel::Unbuffered(JSON::Any)

      @ws.on_message do |message|
        json = JSON.parse(message)
        case json["command"].as_s
        when "init"
          spawn do
            init
          end
        when "node_event"
          data = json["data"]
          node = @nodes[data["id"].as_i]
          spawn do
            @node_events[{node.id, data["event"].as_s}].call(node)
          end
        when "response"
          data = json["data"]
          @pending_responses[data["id"].as_i].send(data["value"])
        end
      end

      @root = Node.new(0)
      @root.app = self
    end

    def init
      @on_init.call self
    end

    def log(message)
      @ws.send %({"command": "log", "data": #{message.to_json}})
    end

    def create_element(tag)
      @last_node_id += 1

      send_command "create" do |json|
        json.field "tag", tag
        json.field "id", @last_node_id
      end

      node = Node.new(@last_node_id)
      node.app = self
      node
    end

    # :nodoc:
    def register_node(node)
      @nodes[node.id] = node
    end

    def node_by_id(id)
      @nodes[id]
    end

    def exec_node(node, method, args)
      send_command "exec_node" do |json|
        json.field "id", node.id
        json.field "method", method
        json.field "args", encode_params(args)
      end
    end

    private def encode_param(arg)
      if arg.is_a?(Node)
        {"__remodi_node_id": arg.id}
      else
        arg
      end
    end

    private def encode_params(args : Enumerable)
      args.map { |arg| encode_param(arg) }.to_a
    end

    def exec_node_wait_response(node, method)
      @last_response_id += 1
      response_id = @last_response_id

      ch = Channel(JSON::Any).new # :: Channel::Unbuffered
      @pending_responses[response_id] = ch

      send_command "exec_node_wait_response" do |json|
        json.field "response_id", response_id
        json.field "id", node.id
        json.field "method", method
        json.field "args", [] of String
      end

      response = ch.receive.raw.to_redomi(self)
      @pending_responses.delete(response_id)

      response
    end

    def on_node_event(node, event, proc : Node -> Void)
      @node_events[{node.id, event}] = proc
      send_command "on_node_event" do |json|
        json.field "id", node.id
        json.field "event", event
      end
    end

    private def send_command(command)
      @ws.send(String.build do |io|
        io.json_object do |json|
          json.field "command", command
          json.field "data" do
            io.json_object do |json|
              yield json, io
            end
          end
        end
      end)
    end
  end
end
