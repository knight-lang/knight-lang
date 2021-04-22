require_relative '../function-spec'

section '4.4.2', 'GET' do
	include Kn::Test::Spec
	# TODO

	#test_argument_count 'IF', '"HI"', '0', '1'
end

__END__
todo: test this

alphabet = ('a'..'z').to_a.join

alphabet.length.times do |len|
	line = alphabet[..len]
	[*0..26].product([*0..26]) do |start, length|
		cmd = %(DUMP GET #{line.inspect} #{start} #{length})
		/\AString\((.*)\)\Z/ =~ (x = `/users/samp/me/knight/cpp/knight -e '#{cmd}'`) or warn "bad: #{x}"
		if line[start, length].to_s != $1
			puts "invalid: <#{cmd}> (got #{x})"
		end
	end
	p len
end
