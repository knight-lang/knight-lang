require 'set'
class Sections
  SECTIONS = {
    function: {
      nullary: %i(TRUE FALSE NULL @ PROMPT RANDOM]),
      unary: %i(: BLOCK CALL QUIT OUTPUT DUMP LENGTH ! ~ ASCII box [ ]),
      binary: %i(+ - * / % ^ < > ? & | ; WHILE),
      ternary: %i(GET IF),
      quaternary: %i(SET),
    },
    types: %i(block boolean integer list null string),
    syntax: %i(encoding whitespace comment integer-literal string-literal parse-variable parse-function),
    variables: %i[],
    extensions: %i(EVAL `)
  }

  class UnknownSection < RuntimeError
  end

  def initialize
    @sections = nil
  end

  def enable(*sections)
    @sections ||= Set.new
    sections.each do |section|
      if section == :all
        @sections 
    raise UnknownSection
  end

  def disable(*sections)
  end
end
