module Kn
	module Test
		Variable = Struct.new :ident
		Function = Struct.new :ast
	end
end


module Kn::Test::Shared
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
			unless system(*Array($executable_to_test), '-e', expr, out: w, err: :close)
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
end
