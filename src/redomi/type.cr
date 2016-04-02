module Redomi
  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(String, Type) | Node
end

class Object
  def to_redomi(app)
    self as Redomi::Type
  end
end

class Array(T)
  def to_redomi(app)
    self.map { |e| e.to_redomi(app) as Redomi::Type }.to_a
  end
end

class Hash(K, V)
  def to_redomi(app)
    if (node_id = self["__remodi_node_id"]?) && node_id.is_a?(Int64)
      app.node_by_id node_id.to_i32
    else
      h = Hash(K, Redomi::Type).new
      self.each do |k, v|
        h[k] = v.to_redomi(app) as Redomi::Type
      end

      h
    end
  end
end
