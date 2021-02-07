require './minruby'

def evaluate(tree)
  case tree[0]
  when "lit"
    return tree[1]
  when "stmts"
    return statements(tree)
  when "func_call"
    # あとの章で消される運命
    return p(evaluate(tree[2]))
  else
    left = evaluate(tree[1])
    right = evaluate(tree[2])
    arithmetic(tree[0], left, right)
  end
end

def statements(tree)
  last = nil
  tree.slice(1..).each { |subtree|
    last = evaluate(subtree)
  }
  last
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
    raise "invalid token: '#{op}'"
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
  str = minruby_load
  tree = minruby_parse(str)
  p(tree)
  evaluate(tree)
end

main
