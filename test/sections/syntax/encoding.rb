require '../../unit/shared'

section 'encoding' do
  it 'parses comments with the required encoding' do
    (KNIGHT_ENCODING - ["\n"]).each do |chr|
      assert_result 12, %|#testing: #{chr}!\n12|
    end
  end

  it 'parses strings with the required encoding' do
    (KNIGHT_ENCODING - ['"', "'"]).each do |chr|
      assert_result chr, %|"#{chr}"|
      assert_result chr, %|'#{chr}'|
    end

    assert_result '"', %|'"'|
    assert_result "'", %|"'"|
  end
end
