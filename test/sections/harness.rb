class TestCase
  def initialize(section, description, when_testing: [], &body)
    @section = section
    @description = description
    @sanitizations = when_testing
    @body = body
  end
end

class Section
  def initialize(parent=nil, name, aliases: [])
    @parent = parent
    @name = name
    @aliases = aliases
    @subsections = []
    @tests = []
  end

  def to_s
    @to_s ||= @parent ? "#@parent.#@name" : @name
  end
  attr_accessor :subsections
  alias inspect to_s

  def load_tests_from_file(filename)
    instance_eval File.read File.join(Dir.pwd, filename)
  end

  def load_tests_from_directory(directory, **k)
    section directory, **k do
      Dir.chdir directory do
        Dir.children('.').each do |file|
          if File.directory? file
            load_tests_from_directory file
          else
            load_tests_from_file file
          end
        end
      end
    end
  end

  def section(name, **k, &block)
    section = Section.new(self, name, **k)
    @subsections.push section
    section.instance_exec(&block)
  end

  def it(*a, **k, &b)
    @tests.push TestCase.new(self, *a, **k, &b)
  end
end
