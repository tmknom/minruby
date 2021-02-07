require './minruby'

def evaluate(tree, env)
  case tree[0]
  when "lit"
    return tree[1]
  when "stmts"
    return statements(tree.slice(1..), env)
  when "var_assign"
    env[tree[1]] = evaluate(tree[2], env)
  when "var_ref"
    return env[tree[1]]
  when "func_call"
    # あとの章で消される運命
    return p(evaluate(tree[2], env))
  else
    left = evaluate(tree[1], env)
    right = evaluate(tree[2], env)
    arithmetic(tree[0], left, right)
  end
end

def statements(tree, env)
  last = nil
  tree.each { |subtree|
    last = evaluate(subtree, env)
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
  str = minruby_load
  tree = minruby_parse(str)
  p(tree)

  env = {}
  evaluate(tree, env)
  p(env)
end

main

def test_ast
  pp(minruby_parse("
x = 1
y = 2 * 3
"))
end

# test_ast
