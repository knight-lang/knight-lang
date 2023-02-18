class TestError < RuntimeError
end

class UncaughtInternalError < TestError
  def initialize(err)
    super "uncaught internal error:\n#{err.full_message}"
  end
end

class ExecutionFailure < TestError
  attr_reader :context, :details

  def initialize(message, details, context)
    @message = message
    @details = details
    @context = context
  end

  def to_s
    "#{@context.testcase}: #@message"
  end

  def details_json
    @details.to_json
  end

  def to_json(*rest)
    {
      testcase: @context.testcase,
      message: @message,
      details: details,
      context: context
    }.to_json(*rest)
  end

  def full_message
    require 'json'
    # return JSON.pretty_generate self# to_json

    headings = {
      'FAILURE' => self,
      'DETAILS' => @details
    }

    headings['CONTEXT'] = @context.to_s if @context.tester.verbose?
    headings['STACKTRACE'] = backtrace.join "\n" if @context.tester.debug?

    headings.map{|k,v| "#{k}\n#{v.to_s.gsub(/^/, '  ')}" }.join "\n"

  end
end

class NonZeroExitStatus < ExecutionFailure
  def initialize(context)
    super "nonzero exit status", context.exit_status, context
  end
end

class StderrNotEmpty < ExecutionFailure
  def initialize(context)
    super "stderr wasn't empty", context.stderr.inspect, context
  end
end

class ParseError < ExecutionFailure
  def initialize(message, context)
    super message, <<~EOS.chomp, context
      escaped: #{context.stdout.inspect}
      unescaped:
      #{context.stdout}
    EOS
  end
end

