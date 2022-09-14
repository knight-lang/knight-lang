require 'minitest'
require 'minitest/spec'

def section(section, name, parallelize: true, &block)
	describe "[#{section}] #{name}" do
		include Kn::Test::Spec
		parallelize_me! if parallelize

		instance_exec(&block)
	end
end

module Kn; end

module Kn::Test
	class BadResult < RuntimeError
		attr_reader :expr, :result

		def initialize(expr, result)
			@expr = expr
			@result = result

			super "\n===[expression]===\n#{@expr}\n===[invalid result]===\n#{@result}\n"
		end
	end

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

	@sanitizations = DEFAULT_SANITIATIONS.dup
	@executable = [File.join(Dir.pwd, 'knight')] # default 

	module_function

	def sanitizations; @sanitizations end
	def sanitizations=(san); @sanitizations = san end
	def executable; @executable end
	def executable=(exec); @executable = Array(exec) end

	def sanitization?(sanitization)
		sanitizations.include? sanitization
	end

	def exec(expr, stdin: :close, stderr: $DEBUG ? $stderr : :close, raise_on_failure: true)
		IO.pipe do |read, write|
			unless system(*executable, '-e', expr, out: write, in: stdin, err: stderr)
				raise BadResult.new(expr, "#$?") if raise_on_failure
			end

			write.close
			read.read
		end
	end
end

module Kn::Test::Spec
  def eval(expr, **k)
    case (result = exec("DUMP #{expr}", **k).chomp)
    when /\A(null|nil|none)(\(\))?\Z/i then :null
    when /\A(?:string|str|text)\((.*?)\)\Z/mi then $1
    when /\A("')(.*?)(\1)/m then %|"#$2"|.undump # FIXME: maybe just regex replace `\"` and `\'`?
    when /\A((?:boolean|bool)?\()?(true|false)(?(1)\)|)\Z/i then $2.downcase == 'true'
    when /\A((?:int|integer|num|number)\()?(\d+)(?(1)\)|)\Z/i then $2.to_i
    else raise Kn::Test::BadResult.new expr, result
    end
  end

	def exec(*a, **k)
		Kn::Test.exec(*a, **k)
	end

	def assert_result(expected, expr)
		assert_equal expected, eval(expr)
	end

	def refute_runs(*a, **k)
		assert_raises Kn::Test::BadResult do
			if block_given?
				yield
			else
				exec(*a, **k)
			end
		end
	end

	def assert_runs(*a, **k)
		if block_given?
			yield
		else
			exec(*a, **k)
		end

		pass
	end

	def to_string(expr)
		eval("+ '' #{expr}").tap { |s| s.is_a? String or raise "not a string: #{val.inspect}" }
	end

	def to_number(expr)
		eval("+ 0 #{expr}").tap { |s| s.is_a? Integer or raise "not an integer: #{val.inspect}" }
	end

	def to_boolean(expr)
		eval("! ! #{expr}").tap { |s| s.is_a? Integer or raise "not a boolean: #{val.inspect}" }
	end

	def self.included(x)
		x.extend self
	end

	def sanitization?(...) 
		Kn::Test.sanitization?(...)
	end
	alias sanitized? sanitization?

	# todo: remove `when_testing` and make it `sanitizes`
	def it(description, when_testing: nil)
		super "[#{when_testing}] #{description}" if !when_testing || sanitization?(when_testing)
	end
end
