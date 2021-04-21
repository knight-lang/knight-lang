require_relative '../../spec'

module Kn::Test::Spec::Function
	include Kn::Test::Spec

	def test_argument_count(name, *args)
		it "requires exactly #{args.length} argument#{args.length == 1 ? '' : 's'}", when_testing: :argument_count do

			args.length.pred.times do |n|
				assert_fails [name, *args[0..n]].join(' ')
			end

			assert_runs [name, *args].join(' ')
		end
	end

	def test_evaluation_order(expected, expression)
		it 'evaluates arguments in order' do
			assert_equal expected, evaluate(expression)
		end
	end

	module Expectation
		def section(*a, &b)
			super(*a) do
				extend Kn::Test::Spec::Function
				include Kn::Test::Spec
				instance_exec(&b)
			end
		end
	end
end

include Kn::Test::Spec::Function::Expectation