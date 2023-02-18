require 'json'
require_relative 'backports'
require_relative 'error'

class Context
  attr_reader :tester, :expression, :stdin, :stdout, :stderr, :exit_status, :test_location, :testcase
  alias result stdout

  # Creates a new `Context` with the given expression. The function `Tester.create_context` is a
  # shorthand for this.
  def initialize(tester, expression, testcase:, test_location:, stdin: nil)
    @tester = tester
    @testcase = testcase
    @test_location = test_location[/^(.*?)(:in `|$)/, 1]
    @expression = expression
    @stdin = stdin
  end

  def to_h
    instance_variables
      .reject { |iv| iv == :@tester || iv == :@testcase }
      .map { |iv| [iv[1..], instance_variable_get(iv)] }
      .to_h
  end

  def to_json(*rest)
    to_h.to_json(*rest)
  end

  def inspect; "Context(#{to_h})"end
  def to_s
    to_h.map{|k,v| "#{k}: #{v.inspect}"}.join("\n")
  end

  def verbose(message)
    return unless @tester.verbose?
    print message
    print " (context=#{to_json})" if @tester.verbose? 
    when 0 then # do nothing
    when 1 then puts message

    log message if @tester.verbose?
  end

  def warn(message)
    log message
  end

  def log(message)
    puts "#{message} (#{self})"
  end

  def execute!(raise_on_failure: true)
    # Create stdin, stdout, and stderr pipes (stdin only if it's provided) 
    out_read, out_write = IO.pipe
    err_read, err_write = IO.pipe
    unless @stdin.nil?
      in_read, in_write = IO.pipe
      in_write.write @stdin
      in_write.close
    end

    # Actually execute the expression and get the exit status.
    verbose "executing expression: #@expression"

    @exit_status = @tester._execute(expression: @expression, in: in_read, out: out_write, err: err_write)

    # Read the stdout and stderr, warning if there's a problem doing that.
    err_write.close rescue warn "unable to close stderr: #$!"
    out_write.close rescue warn "unable to close stdout: #$!"
    @stderr = err_read.read rescue warn("unable to read stderr: #$!")
    @stdout = out_read.read rescue warn("unable to read stdout: #$!")
    verbose "got result: #{@stdout.inspect}"

    # Raise exceptions if there's a problem with executing the test. `raise_on_failure` exists as
    # some tests expect failure (eg `QUIT 1`), and `ignore_all_failures?` exists to bypass these
    # checks (e.g. if the executable always outputs something to stderr)
    if raise_on_failure && !@tester.ignore_all_failures?
      raise NonZeroExitStatus.new(self) unless @exit_status.success?
      raise StderrNotEmpty.new(self) unless @stderr.empty?
    end

    self # return self

  # # If there's any unexpected within this function, then raise an `ExecutionFailure`.
  # rescue => err
  #   raise if err.is_a? ExecutionFailure # `ExecutionFailure` is expected so don't catch it.
  #   error "<internal error>: uncaught exception", err

  # Always close the pipes regardless of what happens (so as to not leave them open). Note that
  # in Ruby, calling `.close` on an already-closed pipe is a no-op and won't raise exceptions.
  ensure
    out_write.close rescue warn "unable to close stdout: #$!"
    err_write.close rescue warn "unable to close stderr: #$!"
    in_write&.close rescue warn "unable to close stdin: #$!"
  end

  def parsed_result
    raise ArgumentError, "stdout isn't set" if @stdout.nil?

    @parsed_result ||= parse!(out = @stdout.dup).tap do
      next if out.empty?
      raise ParseError.new("stdout wasn't exactly one `DUMP` result.", self)
    end
  end

  ESCAPES = {
    '\t'   => "\t",
    '\r'   => "\r",
    '\n'   => "\n",
    '\"'   => "\"",
    '\\\\' => "\\",
  }

  private def parse!(str)
    case 
    when str.delete_prefix!('null') then :null
    when str.delete_prefix!('true') then true
    when str.delete_prefix!('false') then false

    when str.slice!(/\A"((?:\\["\\rnt]|[^"\\])*?)"/) then $1.gsub(/\\./, &ESCAPES)
    when str.slice!(/\A-?\d+/) then $&.to_i

    when str.delete_prefix!('[]') then []
    when str.delete_prefix!('[')
      eles = [parse!(str)]

      until str.delete_prefix! ']'
        str.delete_prefix! ', ' or raise ParseError.new("expected exactly `, ` after element in array", self)
        eles.push parse! str 
      end

      eles
    else
      raise ParseError.new("unknown expression start: #{str[0].inspect}", self)
    end
  end
end
