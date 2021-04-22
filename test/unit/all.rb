Dir.glob File.join(__dir__, '**', 'all.rb') do |testfile|
	require_relative testfile
end
