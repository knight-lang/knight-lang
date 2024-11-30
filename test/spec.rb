# require 'minitest'
# require 'minitest/spec'
# require 'minitest/autorun'

class TestClass
  def initialize(name, &block)
    @name = name
    instance_exec(&block)
  end

  def sanitizes?(what) = $tester.sanitizes?(what)
  alias sanitized? sanitizes?

  def it(description, when_testing: nil, &block)
    if when_testing
      return unless sanitized?(when_testing)
      description.prepend "[#{when_testing}] "
    end

    if @current_test
      fail "<internal bug: currently in a test>"
    end

    @current_test = description
    begin
      instance_exec(&block)
    rescue
      p $!
    ensure
      @current_test = nil
    end
  end

  def assert_result(expected, expression, **k)
    actual = $tester.evaluate(expression, **k)

    if actual != expected
      raise "doesnt work"
    end
  end

  #     expected,
  #     "Offending expression: #{expression.inspect}#{k[:stdin] && " (stdin: #{k[:stdin].inspect})"}"
  #   )
  # end

  # def refute_runs(*a, **k)
  #   assert_raises NonzeroExitStatus, StderrNotEmpty do
  #     if block_given?
  #       yield
  #     else
  #       tester.execute(*a, **k)
  #     end
  #   end
  # end

  # def assert_runs(*a, **k)
  #   if block_given?
  #     yield
  #   else
  #     tester.execute(*a, **k)
  #   end

  #   pass
  # end
end

def section(name, &block)
  TestClass.new(name, &block) 
end

__END__
# def describe()
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
      assert_equal(
        expected,
        tester.evaluate(expr, **k),
        "Offending expression: #{expr.inspect}#{k[:stdin] && " (stdin: #{k[:stdin].inspect})"}"
      )
    end

    def refute_runs(*a, **k)
      assert_raises NonzeroExitStatus, StderrNotEmpty do
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
