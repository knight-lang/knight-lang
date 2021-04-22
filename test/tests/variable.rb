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
			assert_equal ident('_'), eval('BLOCK _')
			assert_equal ident('a'), eval('BLOCK a')
			assert_equal ident('b'), eval('BLOCK b')
			assert_equal ident('z'), eval('BLOCK z')
			refute_kind_of Kn::Test::Variable, eval('BLOCK 0') # digits are not identifiers
			refute_kind_of Kn::Test::Variable, eval('BLOCK R') # upper case letters are not identifiers.
		end

		it 'can have numbers afterwards' do
			assert_equal ident('_ab01_2'), eval('BLOCK _ab01_2')
			assert_equal ident('foobar_12_baz'), eval('BLOCK foobar_12_baz')
			assert_equal ident('__array_123'), eval('BLOCK __array_123')
		end

		it 'ignores trailing capital letters' do
			assert_equal ident('fizz'), eval('BLOCK fizzBuzz')
			assert_equal ident('f'), eval('BLOCK fOO')
			assert_equal ident('_'), eval('BLOCK _XYZ')
			assert_equal ident('ae1'), eval('BLOCK ae1NOPE')
		end
=end
	end

	describe 'assignment and retrieval' do
		it 'must can be assigned to anything' do
			assert_equal :null, eval('= foo NULL')
			assert_equal true, eval('= foo TRUE')
			assert_equal false, eval('= foo FALSE')
			assert_equal 'hi', eval('= foo "hi"')
			assert_equal 123, eval('= foo 123')
			# assert_kind_of Kn::Test::Function, eval('= foo BLOCK + 1 2')
		end

		it 'must return the rhs, but evaluated.' do
			assert_equal 123, eval('= foo (+ 120 3)')
			assert_equal 15, eval('; = x 3 : = foo * x 5')
			assert_equal 15, eval('; = x 15 : = foo x')
		end

=begin
		it 'wont eval its value when it is executed' do
			assert_kind_of Kn::Test::Function, eval('; = foo BLOCK + 1 2 : foo')
			assert_equal ident('bar'), eval('; = foo BLOCK bar : foo')
		end
=end

		it 'will fail on an unknown Variable' do
			assert_fails { eval('unknown') }
		end
	end

	describe 'operators' do
		describe 'CALL' do
=begin
			it 'must return its value when called, but not execute it.' do
				assert_equal ident('baz'), eval('; = foo BLOCK baz ; = bar BLOCK foo : CALL bar')
			end
=end
		end
	end
end
