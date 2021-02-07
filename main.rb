require './minruby'

class Evaluator
  def initialize
    @env = {}
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
      @env[tree[1]] = evaluate!(tree[2])
    when "var_ref"
      return @env[tree[1]]
    when "func_call"
      # あとの章で消される運命
      return p(evaluate!(tree[2]))
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
    pp(@env)
    pp(@profile)
  end
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
i = 10
begin
  p(i)
  i = i - 1
end while i > 0
"))
end

# test_ast
