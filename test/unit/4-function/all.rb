Dir.glob '**/all.rb' do |testfile|
	require_relative testfile
end
