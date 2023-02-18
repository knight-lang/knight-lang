class Tester  
  attr_accessor :executable, :Verbose
  attr_writer :ignore_all_failures, :silent
  alias verbosity verbose
  def verbose?; @verbose.nonzero? end
  def silent?; @silent end
  def debug?; $DEBUG end
  def ignore_all_failures?; @ignore_all_failures end

  def initialize(executable)
    @verbose = 0
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

  def execute(expression, test_location: caller(1, 1)[0], raise_on_failure: true, **kw)
    context = Context.new(self, expression, test_location: test_location, **kw)
    context.execute!(raise_on_failure: raise_on_failure)
    context
  end

  def evaluate(expression, test_location: caller(1, 1)[0], **kw)
    execute("DUMP #{expression}", test_location: test_location, **kw)
  end
end
