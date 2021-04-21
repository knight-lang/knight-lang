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
	@sections = []
	@executable = File.join Dir.pwd, 'knight' # default 

	module_function

	def sanitizations; @sanitizations end
	def sanitizations=(san); @sanitizations = san end
	def sections; @sections end
	def sections=(sec); @sections = sec end
	def executable; @executable end
	def executable=(exec); @executable = Array(exec) end

	def test_section?(section)
		sections.include? section
	end

	def test_sanitization?(sanitization)
		sanitizations.include? sanitization
	end
end

module Kn::Test::Spec
end
# 	class << self
# 		attr_reader :executable
# 		attr_accessor :sanitizations
# 		attr_accessor :sections
# 		self.executable = 
# 	# sections.each do |section|
# 	# 	abort "invalid section '#{section}'" unless section.match? /\A\d+(\.\d+){,2}\z/
# 	# end


# 		def executable=(executable)
# 			executable = Array(executable)
# 			old_executable, @executable = @executable, executable

# 			begin
# 				execute 'DUMP 1'
# 			rescue
# 				# do nothing, fallthroguh
# 			else
# 				return @executable # if we're able to dump, return the executble
# 			end

# 			@executable = old_executable
# 			raise ArgumentError, "invalid executable: #{executable}"
# 		end
# 	end

# 	class InvalidExpression < RuntimeError
# 		attr_reader :expr

# 		def initialize(expr)
# 			@expr = expr
# 			super "invalid expression: #{expr.inspect}"
# 		end
# 	end

# 	def parse(expr)
# 		case expr
# 		when /\ANull\(\)\Z/ then :null
# 		when /\AString\((.*?)\)\Z/m then $1
# 		when /\ABoolean\((true|false)\)\Z/ then $1 == 'true'
# 		when /\ANumber\(((?:-(?!0\)))?\d+)\)\Z/ then $1.to_i # `-0` is invalid.
# 		when /\AFunction\((.*?)\)\Z/m then Kn::Test::Function.new $1
# 		when /\AIdentifier\(([_a-z][_a-z0-9]*)\)\Z/ then Kn::Test::Variable.new $1
# 		else fail "bad expression: #{expr.inspect}"
# 		end
# 	end

# 	module_function def execute(expr, stdin: :close, stdout: :capture, stderr: $DEBUG ? nil : :close, raise_on_failure: true)
# 		IO.pipe do |read, write|
# 			unless system(
# 				*Kn::Test::Spec.executable, '-e', expr,
# 				out: write,
# 				in: stdin,
# 				err: stderr,
# 			)
# 				raise InvalidExpression, expr if raise_on_failure
# 			end

# 			write.close
# 			read.read
# 		end
# 	end

# 	def execute(*a, **k)
# 		Kn::Test::Spec.execute(*a, **k)
# 	end

# 	def assert_fails(cmd=nil)
# 		assert_raises(InvalidExpression) { cmd ? execute(cmd) : yield }
# 	end

# 	def assert_runs(cmd=nil)
# 		cmd ? execute(cmd) : yield
# 		assert true # todo: "pass"
# 	end

# 	def dump(expr, **kwargs)
# 		execute("DUMP #{expr}", **kwargs)
# 	end

# 	def evaluate(expr, **kwargs)
# 		parse dump(expr, **kwargs)
# 	end

# 	def to_string(expr)
# 		val = evaluate "+ '' #{expr}"
# 		raise "not a string: #{val.inspect}" unless val.is_a? String
# 		val
# 	end

# 	def to_number(expr)
# 		val = evaluate "+ 0 #{expr}"
# 		raise "not a number: #{val.inspect}" unless val.is_a? Integer
# 		val
# 	end

# 	def to_boolean(expr)
# 		val = evaluate "! ! #{expr}"
# 		raise "not a boolean: #{val.inspect}" unless val == true || val == false
# 		val
# 	end

# 	def self.included(x)
# 		x.extend self
# 	end

# 	ALL_SANITIZATIONS = [
# 		# division by zero, modulo by zero, and 0 to a negative power.
# 		:zero_division,

# 		# when a bad type is given as the first arg to a binary function
# 		:invalid_types,

# 		# when an identifier/block is given as the fist arg.
# 		:strict_types,

# 		# ensure that the function only parses with the correct amount of arguments
# 		:argument_count,

# 		# Checks to see if overflow occurs on _any_ numeric operation.
# 		:overflow,

# 		# when a bad value is passed to a function
# 		:invalid_values,

# 		# When an undefined variable is accessed
# 		:undefined_variables,

# 		# For things that, while technically UB, are not really that easy to sanitize.
# 		:strict_compliance,

# 		# If we catch problems with i/o. (ie `OUTPUT`, `DUMP`, `PROMPT`, and `` ` ``.)
# 		:io_errors
# 	].freeze

# 	DEFAULT_SANITIATIONS = [
# 		:zero_division,
# 		:invalid_types,
# 		:argument_count,
# 		:undefined_variables
# 	]
# 	SECTIONS = {}

# 	def section(number, name, &block)
# 		# TODO: return unless testing_section? number

# 		describe("#{number}. #{name}", &block)
# 	end

# 	def section(number, name, &block)
# 		# TODO: return unless testing_section? number

# 		describe("#{number}. #{name}", &block)
# 	end

# 	def it(description, when_testing: nil)
# 		super(description) if testing?(*Array(when_testing))
# 	end

# 	def testing?(*value)
# 		value.all? { |x| Kn::Test::Spec.sanitizations.include? x }
# 	end
# end

# module Section
# 	def section(number, name, &block)
# 		# TODO: return unless testing_section? number

# 		describe("#{number}. #{name}", &block)
# 	end
# end
# end

# include Kn::Test::Section
# # def section(number, name, &block)
# # 	# TODO: return unless testing_section? number

# # 	describe("#{number}. #{name}", &block)
# 	# end
