require 'minitest'
require 'minitest/spec'

def section(name, parallelize: true, &block)
  describe name do
    include Kn::Test::Spec
    parallelize_me! if parallelize

    instance_exec(&block)
  end
end

module Kn; end
module Kn::Test
  module Spec
    def self.included(cls)
      cls.extend self
    end

    def tester
      $tester
    end

    def sanitizes?(what) 
      tester.sanitizes?(what)
    end
    alias sanitized? sanitizes?

    def it(description, when_testing: nil, &block)
      if when_testing
        return unless sanitized?(when_testing)
        description.prepend "[#{when_testing}] "
      end

      super(description, &block)
    end

    def assert_result(expected, expr, **k)
      assert_equal expected, tester.evaluate(expr, **k), "Offending expression: #{expr.inspect}"
    end

    def refute_runs(*a, **k)
      assert_raises NonzeroExitStatus do
        if block_given?
          yield
        else
          tester.execute(*a, **k)
        end
      end
    end

    def assert_runs(*a, **k)
      if block_given?
        yield
      else
        tester.execute(*a, **k)
      end

      pass
    end
  end
end
