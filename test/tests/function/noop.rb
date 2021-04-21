require 'minitest'
require 'minitest/spec'
require 'stringio'
require_relative '../shared'

describe '4. Function' do
	include Kn::Test::Shared

	describe '4.2.1 (:)' do
		it 'should return its argument unchanged, but evaluated' do
			assert_equal 0, evaluate(': 0')
			assert_equal 1, evaluate(': 1')
			assert_equal true, evaluate(': TRUE')
			assert_equal false, evaluate(': FALSE')
			assert_equal :null, evaluate(': NULL')
			assert_equal "", evaluate(': ""')
			assert_equal "a", evaluate(': "a"')
			assert_runs { evaluate(': BLOCK QUIT 1') }
			assert_runs { evaluate(': BLOCK a') }
		end
	end
end
