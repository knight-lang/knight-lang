require 'minitest'
require 'minitest/spec'
require_relative 'shared'

describe 'Variable' do
	include Kn::Test::Shared

	def ident(x) Kn::Test::Variable.new(x) end

	describe 'conversions' do
		# Identifiers don't define conversions of their own.
		# Rather, they're ran by other code, which converts them.
	end

	# Note that identifiers
	describe 'parsing' do
=begin
		it 'must start with an lower-case letter or an underscore' do
			assert_equal ident('_'), evaluate('BLOCK _')
			assert_equal ident('a'), evaluate('BLOCK a')
			assert_equal ident('b'), evaluate('BLOCK b')
			assert_equal ident('z'), evaluate('BLOCK z')
			refute_kind_of Kn::Test::Variable, evaluate('BLOCK 0') # digits are not identifiers
			refute_kind_of Kn::Test::Variable, evaluate('BLOCK R') # upper case letters are not identifiers.
		end

		it 'can have numbers afterwards' do
			assert_equal ident('_ab01_2'), evaluate('BLOCK _ab01_2')
			assert_equal ident('foobar_12_baz'), evaluate('BLOCK foobar_12_baz')
			assert_equal ident('__array_123'), evaluate('BLOCK __array_123')
		end

		it 'ignores trailing capital letters' do
			assert_equal ident('fizz'), evaluate('BLOCK fizzBuzz')
			assert_equal ident('f'), evaluate('BLOCK fOO')
			assert_equal ident('_'), evaluate('BLOCK _XYZ')
			assert_equal ident('ae1'), evaluate('BLOCK ae1NOPE')
		end
=end
	end

	describe 'assignment and retrieval' do
		it 'must can be assigned to anything' do
			assert_equal :null, evaluate('= foo NULL')
			assert_equal true, evaluate('= foo TRUE')
			assert_equal false, evaluate('= foo FALSE')
			assert_equal 'hi', evaluate('= foo "hi"')
			assert_equal 123, evaluate('= foo 123')
			# assert_kind_of Kn::Test::Function, evaluate('= foo BLOCK + 1 2')
		end

		it 'must return the rhs, but evaluated.' do
			assert_equal 123, evaluate('= foo (+ 120 3)')
			assert_equal 15, evaluate('; = x 3 : = foo * x 5')
			assert_equal 15, evaluate('; = x 15 : = foo x')
		end

=begin
		it 'wont evaluate its value when it is executed' do
			assert_kind_of Kn::Test::Function, evaluate('; = foo BLOCK + 1 2 : foo')
			assert_equal ident('bar'), evaluate('; = foo BLOCK bar : foo')
		end
=end

		it 'will fail on an unknown Variable' do
			assert_fails { evaluate('unknown') }
		end
	end

	describe 'operators' do
		describe 'CALL' do
=begin
			it 'must return its value when called, but not execute it.' do
				assert_equal ident('baz'), evaluate('; = foo BLOCK baz ; = bar BLOCK foo : CALL bar')
			end
=end
		end
	end
end
