class Tester  
  attr_accessor :executable
  attr_writer :verbose, :ignore_all_failures

  def initialize(executable)
    @executable = executable
  end

  def execute(expression, stdin: nil, raise_on_failure: true)
    TestCase.new(self, expression, stdin: stdin).execute!(raise_on_failure: raise_on_failure)
  end

  def evaluate(expression, **kw)
    execute("DUMP #{expression}", **kw)
  end

  def verbose?; @verbose end
  def ignore_all_failures?; @ignore_all_failures end

  # allow for overwriting it
  def _execute(expression:, in:, out:, err:)
    kwargs = {
      in: binding.local_variable_get(:in),
      out: out,
      err: err
    }.compact # get rid of `stdin` if it's not supplied

    system(*Array(@executable), '-e', expression, **kwargs)
    $?
  end
end

tester = Tester.new(File.join(Dir.pwd, 'knight'))
tester.executable = Dir.home + "/code/knight/c/ast/bin/knight"
p tester.execute("DUMP +@'hello, world'")   

class Sanitizer
  ALL_SANITIZATIONS = [
    # division by zero, modulo by zero, and 0 to a negative power.
    :zero_division,

    # when a bad type is given as the first arg to a binary function
    :invalid_types,

    # when an identifier/block is given as the fist arg.
    :strict_types,

    # ensure that the function only parses with the correct amount of arguments
    :argument_count,

    # Checks to see if overflow occurs on _any_ numeric operation.
    :overflow,

    # when a bad value is passed to a function
    :invalid_values,

    # When an undefined variable is accessed
    :undefined_variables,

    # For things that, while technically UB, are not really that easy to sanitize.
    :strict_compliance,

    # If we catch problems with i/o. (ie `OUTPUT`, `DUMP`, `PROMPT`, and `` ` ``.)
    :io_errors,
  ].freeze

  DEFAULT_SANITIATIONS = [
    :zero_division,
    :invalid_types,
    :argument_count,
    :undefined_variables
  ].freeze

  attr_accessor :sanitizations
  alias sanitizers 

    attr_accessor :sanitizations, :executable

    def initialize(sanitizations: DEFAULT_SANITIATIONS.dup, executable: nil, &block)
      @sanitizations = sanitizations
      @executable = block || executable or raise ArgumentError, "either a block or executable must be given"
    end


__END__

module Kn; end
module Kn::Test
  class Tester

    attr_accessor :sanitizations, :executable

    def initialize(sanitizations: DEFAULT_SANITIATIONS.dup, executable: nil, &block)
      @sanitizations = sanitizations
      @executable = block || executable or raise ArgumentError, "either a block or executable must be given"
    end

    def sanitizes?(sanitization)
      sanitizations.include?(sanitization)
    end
    alias sanitized? sanitizes?

    def execute(expr, stdin: :close, raise_on_failure: true)
      IO.pipe do |out_read, out_write|
        IO.pipe do |err_read, err_write|
          IO.pipe do |in_read, in_write|
            if stdin == :close
              in_read = stdin
            else
              in_write.write stdin
              in_write.close
            end

            status = if @executable.respond_to? :call
              @executable.call(expr, out: out_write, in: in_read, err: err_write)
            else
              system(*Array(executable), '-e', expr, out: out_write, 
                # in: in_read,
                err: err_write)
              $?
            end

            if !status.success? && raise_on_failure
              raise NonzeroExitStatus.new(expr, status)
            end

            err_write.close
            unless (err = err_read.read).empty?
              raise StderrNotEmpty.new(expr, err)
            end

            out_write.close
            out_read.read
          end
        end
      end
    end

    def evaluate(expression, **k)
      result = execute("DUMP #{expression}", **k)

      catch :parse_error do
        return parse result
      end

      raise CannotParse.new(expression, result)
    end

    def parse(orig)
      parse!(str = orig.dup).tap do
        throw :parse_error unless str.empty?
      end
    end

    ESCAPES = {
      '\t'   => "\t",
      '\r'   => "\r",
      '\n'   => "\n",
      '\"'   => "\"",
      '\\\\' => "\\",
    }

    def parse!(str)
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
          str.delete_prefix! ', ' or throw :parse_error
          eles.push parse! str 
        end
        eles
      else throw :parse_error
      end
    end
  end
end
