require_relative '../function-spec'

section '4.5.1', 'SUBSTITUTE' do
	include Kn::Test::Spec
	# TODO

	test_argument_count 'SUBS', '"HI"', '0', '1', '"BA"'
end
__END__
todo: this. also this doens't account for empty strings.
alphabet = ('a'..'k').to_a.join

alphabet.length.times do |len|
	line = alphabet[..len]
	[*0..len].product([*0..len], [*0..10]) do |start, length, repl|
		repl = alphabet[..len]
		cmd = %(DUMP SUBS #{line.inspect} #{start} #{length} #{repl.inspect})
		/\AString\((.*)\)\Z/ =~ (x = `/users/samp/me/knight/cpp/knight -e '#{cmd}'`) or warn "bad: #{x}"

		tmp = (line.to_s).dup
		tmp[start, length] = repl
		if tmp != $1
			puts "invalid: <#{cmd}> (got #{x})"
		end
	end
	p len
end