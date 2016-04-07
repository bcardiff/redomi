module Redomi::SVG
  class SVGElement < Node
    def self.namespace
      "http://www.w3.org/2000/svg"
    end
  end

  class SVG < SVGElement
    tag_name "svg"
  end

  class Circle < SVGElement
    tag_name "circle"
  end

  class Rect < SVGElement
    tag_name "rect"
  end
end
