require 'set'

class Sections
  class Section
    attr_reader :name, :path
    def initialize(name:, path:)
      @name = name
      @path = File.join('unit', *path.split('/'))
    end

    def ==(rhs)
      [@name[0], @name].any? { |x| rhs.casecmp? x}
    end

    def inspect
      @name.inspect
    end

    def require
      require_relative @path
    end
  end

  ALL = [
    *FUNCTION = [
      *NULLARY = [
        Section.new(name: '@',      path: 'function/nullary/emptylist'),
        Section.new(name: 'FALSE',  path: 'function/nullary/false'),
        Section.new(name: 'NULL',   path: 'function/nullary/null'),
        Section.new(name: 'PROMPT', path: 'function/nullary/prompt'),
        Section.new(name: 'RANDOM', path: 'function/nullary/random'),
        Section.new(name: 'TRUE',   path: 'function/nullary/true'),
      ],
      *UNARY = [
        Section.new(name: 'ASCII',  path: 'function/unary/ascii'),
        Section.new(name: 'BLOCK',  path: 'function/unary/block'),
        BOX=Section.new(name: ',',  path: 'function/unary/box'),
        Section.new(name: 'CALL',   path: 'function/unary/call'),
        Section.new(name: 'DUMP',   path: 'function/unary/dump'),
        Section.new(name: '[',      path: 'function/unary/head'),
        Section.new(name: 'LENGTH', path: 'function/unary/length'),
        Section.new(name: '~',      path: 'function/unary/negate'),
        Section.new(name: ':',      path: 'function/unary/noop'),
        Section.new(name: '!',      path: 'function/unary/not'),
        Section.new(name: 'OUTPUT', path: 'function/unary/output'),
        Section.new(name: 'QUIT',   path: 'function/unary/quit'),
        Section.new(name: ']',      path: 'function/unary/tail'),
      ],
      *BINARY = [
        Section.new(name: '+',     path: 'function/binary/add'),
        Section.new(name: '&',     path: 'function/binary/and'),
        Section.new(name: '=',     path: 'function/binary/assign'),
        Section.new(name: '/',     path: 'function/binary/divide'),
        Section.new(name: '?',     path: 'function/binary/equals'),
        Section.new(name: '^',     path: 'function/binary/exponentiate'),
        Section.new(name: '>',     path: 'function/binary/greater-than'),
        Section.new(name: '<',     path: 'function/binary/less-than'),
        Section.new(name: '%',     path: 'function/binary/modulo'),
        Section.new(name: '*',     path: 'function/binary/multiply'),
        Section.new(name: '|',     path: 'function/binary/or'),
        Section.new(name: '-',     path: 'function/binary/subtract'),
        Section.new(name: ';',     path: 'function/binary/then'),
        Section.new(name: 'WHILE', path: 'function/binary/while'),
      ],
      *TERNARY = [
        Section.new(name: 'GET', path: 'function/ternary/get'),
        Section.new(name: 'IF',  path: 'function/ternary/if'),
      ],
      *QUATERNARY = [
        Section.new(name: 'SET', path: 'function/quaternary/set'),
      ],
    ],

    *SYNTAX = [
      Section.new(name: 'comment',         path: 'syntax/comment'),
      Section.new(name: 'whitespace',      path: 'syntax/whitespace'),
      Section.new(name: 'encoding',        path: 'syntax/encoding'),
      Section.new(name: 'integer-literal', path: 'syntax/integer-literal'),
      Section.new(name: 'string-literal',  path: 'syntax/string-literal'),
      Section.new(name: 'variable',        path: 'syntax/variable'),
    ],

    *TYPES = [
      Section.new(name: 'block',   path: 'types/block'),
      Section.new(name: 'boolean', path: 'types/boolean'),
      Section.new(name: 'integer', path: 'types/integer'),
      Section.new(name: 'list',    path: 'types/list'),
      Section.new(name: 'null',    path: 'types/null'),
      Section.new(name: 'string',  path: 'types/string'),
    ],

    *VARIABLE = [
      Section.new(name: 'variable', path: 'variable/variable')
    ],
  ]

  *EXTENSIONS = [
    Section.new(name: 'eval', path: 'syntax/eval'),
    Section.new(name: 'system', path: 'syntax/system'),
  ]

  attr_accessor :sections

  def initialize(sections = ALL)
    @sections = sections.to_set
  end

  def clear
    @sections.clear
  end

  class UnknownSection < RuntimeError
    def initialize(section)
      super "Unknown section #{section.inspect}"
    end
  end

  def lookup(section)
    case section.downcase.to_sym
    when :all then ALL
    when :function, :functions then FUNCTION
    when :nullary then NULLARY
    when :unary then UNARY
    when :binary then BINARY
    when :ternary then TERNARY
    when :quaternary then QUATERNARY
    when :types then TYPES
    when :syntax then SYNTAX
    when :variable then VARIABLE
    when :extension, :extensions, :exts then EXTENSIONS
    when :box then [BOX]
    else
      [ALL.find { |x| x == section.to_s } || raise(UnknownSection.new(section))]
    end
  end

  def enable(*sections)
    sections = [:all] if sections.empty?

    sections.each do |section|
      @sections.merge lookup section
    end
  end

  def disable(*sections)
    sections = [:all] if sections.empty?

    sections.each do |section|
      @sections.subtract lookup section
    end
  end

  def require
    @sections.each(&:require)
  end
end
