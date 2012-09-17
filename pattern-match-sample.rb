require "bundler/setup"
require "pattern-match"
require "pp"

class Tree
  class Node
    attr_accessor :value, :left, :right

    include PatternMatch::Deconstructable

    def initialize(value)
      @value = value
      @left = Empty.new
      @right = Empty.new
    end

    def self.deconstruct(node)
      if !(node.class.to_s == "Tree::Node" || node.class.to_s == "Tree::Empty")
        raise PatternMatch::PatternNotMatch
      end

      [node.left, node.value, node.right]
    end
  end

  class Empty < Node
    include PatternMatch::Deconstructable

    def value
      nil
    end

    def left
      nil
    end

    def right
      nil
    end

    def initialize
    end

    def self.deconstruct(empty)
      if !(empty.class.to_s == "Tree::Empty")
        raise PatternMatch::PatternNotMatch
      end

      [empty]
    end
  end

  attr_reader :root
  def initialize(value)
    @root = Node.new(value)
  end

  def insert(node, to = root)
    match(to) {
      with(Node.(Empty.(lempty), value, Empty.(rempty))) {
        if value < node.value
          to.right = node
        else
          to.left = node
        end
      }

      with(Node.(Empty.(lempty), value, right & Node.(rl, rv, rr))) {
        if value < node.value
          insert(node, right)
        else
          to.left = node
        end
      }

      with(Node.(left & Node.(ll, lv, lr), value, Empty.(rempty))) {
        if value < node.value
          to.right = node
        else
          insert(node, left)
        end
      }

      with(Node.(left & Node.(ll, lv, lr), value, right & Node.(rl, rv, rr))) {
        if value < node.value
          insert(node, right)
        else
          insert(node, left)
        end
      }
    }
  end

  def find(n, to = root)
    match(to) {
      with(Node.(Empty.(lempty), value, Empty.(rempty))) {
        if value == n
          value
        else
          nil
        end
      }

      with(Node.(Empty.(lempty), value, right & Node.(rl, rv, rr))) {
        if value == n
          return n
        elsif value < n
          find(n, right)
        else
          nil
        end
      }

      with(Node.(left & Node.(ll, lv, lr), value, Empty.(rempty))) {
        if value == n
          return n
        elsif value < n
          nil
        else
          find(n, left)
        end
      }

      with(Node.(left & Node.(ll, lv, lr), value, right & Node.(rl, rv, rr))) {
        if value == n
          return n
        elsif value < n
          find(n, right)
        else
          find(n, left)
        end
      }
    }
  end
end

node = Tree::Node.new(5)

match(node) {
  with(Tree::Node.(left, value, right)) {
    pp [left, value, right]
  }
}

puts "----------------------------------------"

tree = Tree.new(100)
30.times do
  tree.insert(Tree::Node.new(rand(200)))
end

pp tree

puts "----------------------------------------"

tree.insert(Tree::Node.new(120))
p tree.find(120)
p tree.find(1000)
