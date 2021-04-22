require 'minitest/autorun'
require_relative 'spec'

# $".last

# p caller
# exit

# only run the last file to be included
# if $* == caller(-1)
p caller
Kn::Test.sections = [Kn::Test::KNOWN_SECTIONS.last]
