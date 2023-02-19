require_relative 'harness'

(s = Section.new('all')).load_tests_from_directory 'syntax'
pp s.subsections[0].subsections

