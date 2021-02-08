require './minruby'

class Evaluator
  def initialize
    @genv = {
      "p" => %w[builtin p],
      "add" => %w[builtin my_add],
    }
    @profile = {}
  end

  def evaluate(tree)
    begin
      evaluate!(tree, {})
    rescue => e
      debug(tree)
      raise e
    end
  end

  def evaluate!(tree, lenv)
    update_profile(tree[0])

    case tree[0]
    when "lit"
      return tree[1]
    when "ary_new"
      return ary_new(tree, lenv)
    when "ary_ref"
      return ary_ref(tree, lenv)
    when "ary_assign"
      return ary_assign(tree, lenv)
    when "stmts"
      return statements(tree.slice(1..), lenv)
    when "if"
      return if_statement(tree, lenv)
    when "while"
      return while_statement(tree, lenv)
    when "while2"
      return begin_while_statement(tree, lenv)
    when "var_assign"
      lenv[tree[1]] = evaluate!(tree[2], lenv)
    when "var_ref"
      return lenv[tree[1]]
    when "func_def"
      @genv[tree[1]] = ["user_defined", tree[2], tree[3]]
    when "func_call"
      return func_call(tree, lenv)
    else
      left = evaluate!(tree[1], lenv)
      right = evaluate!(tree[2], lenv)
      arithmetic(tree[0], left, right)
    end
  end

  def ary_new(tree, lenv)
    ary = []
    tree.slice(1..).each_with_index { |subtree, i|
      ary[i] = evaluate!(subtree, lenv)
    }
    ary
  end

  def ary_ref(tree, lenv)
    ary = evaluate!(tree[1], lenv)
    idx = evaluate!(tree[2], lenv)
    ary[idx]
  end

  def ary_assign(tree, lenv)
    ary = evaluate!(tree[1], lenv)
    idx = evaluate!(tree[2], lenv)
    val = evaluate!(tree[3], lenv)
    ary[idx] = val
  end

  def if_statement(tree, lenv)
    if evaluate!(tree[1], lenv)
      evaluate!(tree[2], lenv)
    else
      evaluate!(tree[3], lenv)
    end
  end

  def while_statement(tree, lenv)
    while evaluate!(tree[1], lenv)
      evaluate!(tree[2], lenv)
    end
  end

  def begin_while_statement(tree, lenv)
    begin
      evaluate!(tree[2], lenv)
    end while evaluate!(tree[1], lenv)
  end

  def statements(tree, lenv)
    last = nil
    tree.each { |subtree|
      last = evaluate!(subtree, lenv)
    }
    last
  end

  def func_call(tree, lenv)
    args = []
    tree.slice(2..).each_with_index { |subtree, i|
      args[i] = evaluate!(subtree, lenv)
    }
    mhd = @genv[tree[1]]
    if mhd[0] == "builtin"
      minruby_call(mhd[1], args)
    else
      new_lenv = {}
      params = mhd[1]
      params.each_with_index { |param, i|
        new_lenv[param] = args[i]
      }
      evaluate!(mhd[2], new_lenv)
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
    when ">="
      left >= right
    when "<="
      left <= right
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
    pp(@genv)
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
  # evaluator.debug(tree)
end

main

def test_ast
  pp(minruby_parse("
array = [1, 2, 3]
array[0] = 42
"))
end

# test_ast
