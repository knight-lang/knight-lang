class Failure
  def initialize(tester, testcase, message, context)
    @tester, @testcase, @message, @context = tester, testcase, message, context
  end

  def to_s
    <<~EOS
      FAILURE: #@testcase
      #@error
      #@context
    EOS
  end
end

class Tester  
  attr_accessor :executable
  attr_writer :verbose, :ignore_all_failures, :silent
  def verbose?; @verbose end
  def silent?; @silent end
  def ignore_all_failures?; @ignore_all_failures end

  def initialize(executable)
    @executable = executable
  end

  def _execute(expression:, in:, out:, err:)
    kwargs = {
      in: binding.local_variable_get(:in),
      out: out,
      err: err
    }.compact # get rid of `stdin` if it's not supplied

    if @executable.respond_to? :call
      @executable.call(expression: expression, **kwargs)
    else
      system(*Array(@executable), '-e', expression, **kwargs)
      $?
    end
  end

  def execute(expression, stdin: nil, test_location: caller(1, 1)[0], raise_on_failure: true)
    context = Context.new(self, expression, test_location: test_location, stdin: stdin)
    context.execute!(raise_on_failure: raise_on_failure)
    context
  end

  def evaluate(expression, test_location: caller(1, 1)[0], **kw)
    execute("DUMP #{expression}", test_location: test_location, **kw)
  end

  def failure(testcause, error, context = error.context)
    Failure.new(self, testcause, error, context).tap do |failure|
      $stderr.puts "[F] #{failure}" unless silent?
    end
  end
end
