require 'minitest'
require 'minitest/spec'

module Kn
	module Test
		Variable = Struct.new :ident
		Function = Struct.new :ast
	end
end


module Kn::Test::Spec
	class InvalidExpression < Exception
		attr_reader :expr

		def initialize(expr)
			@expr = expr
			super "invalid expression: #{expr.inspect}"
		end
	end

	def parse(expr)
		case expr
		when /\ANull\(\)\Z/ then :null
		when /\AString\((.*?)\)\Z/m then $1
		when /\ABoolean\((true|false)\)\Z/ then $1 == 'true'
		when /\ANumber\(((?:-(?!0\)))?\d+)\)\Z/ then $1.to_i # `-0` is invalid.
		when /\AFunction\((.*?)\)\Z/m then Kn::Test::Function.new $1
		when /\AIdentifier\(([_a-z][_a-z0-9]*)\)\Z/ then Kn::Test::Variable.new $1
		else fail "bad expression: #{expr.inspect}"
		end
	end

	def execute(expr, raise_on_failure: true)
		IO.pipe do |r, w|
			unless system(
				*Array($executable_to_test), '-e', expr,
				out: w,
				in: $stdin,
				**($DEBUG ? {} : { err: :close })
			)
				raise InvalidExpression, expr if raise_on_failure
			end

			w.close
			r.read
		end
	end

	def assert_fails
		assert_raises(InvalidExpression) { yield }
	end

	def assert_runs
		yield
	end

	def dump(expr)
		execute("D #{expr}")
	end

	def check_ub?
		$check_ub
	end

	def eval(expr)
		parse dump expr
	end

	def to_string(expr)
		val = eval "+ '' #{expr}"
		raise "not a string: #{val.inspect}" unless val.is_a? String
		val
	end

	def to_number(expr)
		val = eval "+ 0 #{expr}"
		raise "not a number: #{val.inspect}" unless val.is_a? Integer
		val
	end

	def to_boolean(expr)
		val = eval "! ! #{expr}"
		raise "not a boolean: #{val.inspect}" unless val == true || val == false
		val
	end


	def self.included(x)
		x.extend self
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

		# when a value 
		:invalid_values,
	].freeze

	$enabled_sanitizations ||= [
		:zero_division,
		:invalid_types,
		:argument_count
	]

	def it(description, when_testing: nil)
		super(description) if testing?(*Array(when_testing))
	end

	def testing?(*value)
		value.all? { |x| $enabled_sanitizations.include? x }
	end

	def basic_sanitization?
		1 <= $sanitization
	end

	def advanced_sanitiation?
		2 <= $sanitization
	end
end
