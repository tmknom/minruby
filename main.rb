require './minruby'

def evaluate(tree)
  if tree[0] == "lit"
    return tree[1]
  end

  left = evaluate(tree[1])
  right = evaluate(tree[2])
  arithmetic(tree[0], left, right)
end

def arithmetic(op, left, right)
  case op
  when "+"
    left + right
  when "-"
    left - right
  when "*"
    left * right
  when "/"
    left / right
  when "%"
    left % right
  when "**"
    left ** right
  when ">"
    left > right
  when "<"
    left < right
  when "=="
    left == right
  else
    raise "invalid token: '#{tree[0]}'"
  end
end

def max_leaf(tree)
  if tree[0] == "lit"
    return tree[1]
  end

  left = max_leaf(tree[1])
  right = max_leaf(tree[2])

  if left > right
    left
  else
    right
  end
end

def main
  # str = gets
  str = "5 * 12 + 6 / 2"
  tree = minruby_parse(str)
  p(tree)
  p(evaluate(tree))
  p(max_leaf(tree))
end

main
