require './minruby'

class Evaluator
  def initialize
    @lenv = {}
    @genv = {
      "p" => %w[builtin p],
      "add" => %w[builtin my_add],
    }
    @profile = {}
  end

  def evaluate(tree)
    begin
      evaluate!(tree)
    rescue => e
      debug(tree)
      raise e
    end
  end

  def evaluate!(tree)
    update_profile(tree[0])

    case tree[0]
    when "lit"
      return tree[1]
    when "stmts"
      return statements(tree.slice(1..))
    when "if"
      return if_statement(tree)
    when "while"
      return while_statement(tree)
    when "while2"
      return begin_while_statement(tree)
    when "var_assign"
      @lenv[tree[1]] = evaluate!(tree[2])
    when "var_ref"
      return @lenv[tree[1]]
    when "func_call"
      return func_call(tree)
    else
      left = evaluate!(tree[1])
      right = evaluate!(tree[2])
      arithmetic(tree[0], left, right)
    end
  end

  def if_statement(tree)
    if evaluate!(tree[1])
      evaluate!(tree[2])
    else
      evaluate!(tree[3])
    end
  end

  def while_statement(tree)
    while evaluate!(tree[1])
      evaluate!(tree[2])
    end
  end

  def begin_while_statement(tree)
    begin
      evaluate!(tree[2])
    end while evaluate!(tree[1])
  end

  def statements(tree)
    last = nil
    tree.each { |subtree|
      last = evaluate!(subtree)
    }
    last
  end

  def func_call(tree)
    args = []
    tree.slice(2..).each_with_index { |subtree, i|
      args[i] = evaluate!(subtree)
    }
    mhd = @genv[tree[1]]
    if mhd[0] == "builtin"
      minruby_call(mhd[1], args)
    else

    end
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

  def update_profile(token)
    if @profile[token] == nil
      @profile[token] = 1
    else
      @profile[token] += 1
    end
  end

  def debug(tree)
    pp(tree)
    pp(@lenv)
    pp(@profile)
  end
end

def my_add(x, y)
  x + y
end

def main
  str = minruby_load
  tree = minruby_parse(str)

  evaluator = Evaluator.new
  evaluator.evaluate(tree)
end

main

def test_ast
  pp(minruby_parse("
p(1)
p(1,2)
"))
end

# test_ast
