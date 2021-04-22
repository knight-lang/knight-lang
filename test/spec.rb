require 'minitest'
require 'minitest/spec'

module Kn; end

module Kn::Test
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
	@sections = :all
	@executable = [File.join(Dir.pwd, 'knight')] # default 

	module_function

	def sanitizations; @sanitizations end
	def sanitizations=(san); @sanitizations = san end
	def sections; @sections end
	def sections=(sec); @sections = sec end
	def executable; @executable end
	def executable=(exec); @executable = Array(exec) end

	def section?(section)
		@sections == :all || @sections.include?(section)
	end

	def sanitization?(sanitization)
		sanitizations.include? sanitization
	end
end

module Kn::Test::Spec
	class BadResult < RuntimeError
		attr_reader :expr, :result

		def initialize(expr, result)
			@expr = expr
			@result = result

			super "\n===[expression]===\n#{@expr.inspect}\n===[invalid result]===\n#{@result.inspect}\n"
		end
	end

	def eval(expr, **k)
		case (result = exec("DUMP #{expr}", **k).chomp)
		when /\ANull\(\)\z/                    then :null
		when /\AString\((.*?)\)\z/m            then $1
		when /\ABoolean\((?i)(true|false)\)\z/ then $1.downcase == 'true'
		when /\ANumber\((?!-0\b)(-?\d+)\)\z/   then $1.to_i # `-0` is invalid.
		else                                        raise BadResult.new expr, result
		end
	end

	def exec(expr, stdin: :close, stderr: $DEBUG ? $stderr : :close, raise_on_failure: true)
		unless File.executable? Kn::Test.executable.first
			abort "executable file #{Kn::Test.executable.first.inspect} is not executable"
		end

		IO.pipe do |read, write|
			unless system(*Kn::Test.executable, '-e', expr, out: write, in: stdin, err: stderr)
				raise BadResult.new(expr, "#$?") if raise_on_failure
			end

			write.close
			read.read
		end
	end

	def assert_run_equal(expected, expr)
		assert_equal expected, eval(expr)
	end

	def refute_runs(*a, **k)
		assert_raises BadResult do
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

	def section?(...)
		Kn::Test.section?(...)
	end
	def sanitization?(...) 
		Kn::Test.sanitization?(...)
	end

	def section(number, name, &block)
		describe("#{number}. #{name}", &block) if section? number
	end

	# todo: remove `when_testing` and make it `sanitizes`
	def it(description, when_testing: nil, sanitizes: when_testing)
		super description if !sanitizes || sanitization?(sanitizes)
	end

	module Section
		include Kn::Test::Spec
	end
end

def section(number, name, &block)
	describe "#{number}. #{name}" do
		include Kn::Test::Spec

		instance_exec(&block)
	end
end
