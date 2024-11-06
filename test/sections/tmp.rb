require_relative 'section'

(s = Section.new('all'))#.load_tests_from_directory 'syntax'
Dir.children('.').each do 
  next unless File.directory? _1
  s.load_tests_from_directory _1
end
pp s.children


# pp s.subsections[0].subsections

