Dir.glob File.join(__dir__, '*.rb') do |testfile|
	require_relative testfile
end
