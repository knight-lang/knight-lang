require_relative 'sections'
require_relative 'sanitizer'

class Tester
  attr_reader :executable, :sections, :sanitizer
  attr_writer :debug, :verbose

  def debug?; @debug end
  def verbose?; @verbose end
  def executable=(value) @executable = Array value end

  def initialize(executable:)
    @executable = executable
    @verbose = false
    @debug = false
    @sections = Sections.new
    @sanitizer = Sanitizer.new
  end

  def execute(expression:, stdin:, stdout:, stderr:)
    kwargs = { in: stdin, out: stdout, err: stderr }.compact

    if @executable.respond_to?(:call)
      return @executable.call(expression, **kwargs)
    end

    system(*@executable, '-e', expression, **kwargs)
    $?
  end

  def should_test?(section)
    true
  end
end


# class Tester  
#   attr_accessor :executable, :verbose
#   attr_writer :ignore_all_failures, :silent
#   alias verbosity verbose
#   def verbose?; @verbose.nonzero? end
#   def silent?; @silent end
#   def debug?; $DEBUG end
#   def ignore_all_failures?; @ignore_all_failures end

#   def initialize(executable)
#     @verbose = 0
#     @executable = executable
#   end

#   def _execute(expression:, in:, out:, err:)
#     kwargs = {
#       in: binding.local_variable_get(:in),
#       out: out,
#       err: err
#     }.compact # get rid of `stdin` if it's not supplied

#     if @executable.respond_to? :call
#       @executable.call(expression: expression, **kwargs)
#     else
#       system(*Array(@executable), '-e', expression, **kwargs)
#       $?
#     end
#   end

#   def execute(expression, test_location: caller(1, 1)[0], raise_on_failure: true, **kw)
#     context = Execution.new(self, expression, test_location: test_location, **kw)
#     context.execute!(raise_on_failure: raise_on_failure)
#     context
#   end

#   def evaluate(expression, test_location: caller(1, 1)[0], **kw)
#     execute("DUMP #{expression}", test_location: test_location, **kw)
#   end
# end
