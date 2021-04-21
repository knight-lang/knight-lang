require_relative '../../../autorun' if $0 == __FILE__

sDir.glob File.join(__dir__, '*.rb') do |testfile|
	require_relative testfile
end
