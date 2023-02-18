require_relative 'tester'
require_relative 'context'

class TestContext
  def initialize(testcase, tester)
    @testcase = testcase
    @tester = tester
  end

  def assert_result(expected, expression)
    result = @tester.evaluate expression, test_location: caller(1, 1)[0], testcase: @testcase

    return if expected == result.parsed_result

    result.error <<~EOS, caller(1)
      bad result for expression: #{expression.inspect}
        expected: #{expected.inspect}
        actual:   #{result.parsed_result.inspect}
    EOS
  end
end

class TestCase
  def initialize(sections, description, sanitizations, body)
    @sections, @description, @sanitizations, @body = sections, description, sanitizations, body
  end

  def should_run?(sections:, sanitizations:)
    # sanitization.zip(@sections)
    true
  end

  def to_s
    @to_s ||= "#{@sections.join('.')}.#{@description.inspect}"
  end

  def run(tester)
    TestContext.new(self, tester).instance_exec(&@body)
  # rescue ExecutionFailure => err
  #   tester.failure(self, err)
  # rescue => err
  #   Failure.new(self, "<uncaught internal error>: #{err.full_backtrace}", Context.new)
  end
end

class Harness
  def initialize
    @tests = []
    @current_scopes = []
  end

  def section(name)
    @current_scopes.push name
    yield
  ensure
    @current_scopes.pop
  end

  alias describe section

  def it(description, when_testing: nil, &block)
    @tests.push TestCase.new(@current_scopes.dup, description, when_testing, block)
  end

  def run(tester, print_test_results: true, **kwargs)
    failures = []

    @tests.each do |test|
      test.run(tester) if test.should_run?(**kwargs)
      puts '.' if print_test_results

    rescue TestError => err
      failures.push err
      puts 'E' if print_test_results

    rescue => unexpected_err
      failures.push UncaughtInternalError.new(unexpected_err)
      puts '!' if print_test_results
    end

    failures
  end
end

# p @scopes
__END__

require_relative '../shared'

section 'boolean' do
  describe 'parsing' do
    it 'parses `F` and `FALSE` as false' do
      assert_result false, %|F|
      assert_result false, %|FALSE|
    end
