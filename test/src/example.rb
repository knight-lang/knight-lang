require_relative 'harness'

# require_relative './context'
$tester = Tester.new(File.join(Dir.pwd, 'knight'))
$tester.executable = Dir.home + "/code/knight/c/ast/bin/knight"
$tester.verbose = true

h = Harness.new
h.section 'function' do
  h.describe 'unary' do
    h.describe '+' do
      h.it 'adds properly' do
        assert_result 4, 'QO3'
      end
    end
  end
end

h.run($tester, sections: [], sanitizations: []).each do |failure|
  puts failure.full_message
end
