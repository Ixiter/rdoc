# coding: UTF-8
# frozen_string_literal: false

require 'rdoc/test_case'

class TestRDocRubyLex < RDoc::TestCase

  def setup
    @TK = RDoc::RubyToken
  end

  def test_token_position
    tokens = RDoc::RubyLex.tokenize '[ 1, :a, nil ]', nil

    assert_equal '[', tokens[0].text
    assert_equal 0, tokens[0].seek
    assert_equal 1, tokens[0].line_no
    assert_equal 0, tokens[0].char_no
    assert_equal '1', tokens[2].text
    assert_equal 2, tokens[2].seek
    assert_equal 1, tokens[2].line_no
    assert_equal 2, tokens[2].char_no
    assert_equal ':a', tokens[5].text
    assert_equal 5, tokens[5].seek
    assert_equal 1, tokens[5].line_no
    assert_equal 5, tokens[5].char_no
    assert_equal 'nil', tokens[8].text
    assert_equal 9, tokens[8].seek
    assert_equal 1, tokens[8].line_no
    assert_equal 9, tokens[8].char_no
    assert_equal ']', tokens[10].text
    assert_equal 13, tokens[10].seek
    assert_equal 1, tokens[10].line_no
    assert_equal 13, tokens[10].char_no
  end

  def test_class_tokenize
    tokens = RDoc::RubyLex.tokenize "def x() end", nil

    expected = [
      @TK::TkDEF       .new( 0, 1,  0, "def"),
      @TK::TkSPACE     .new( 3, 1,  3, " "),
      @TK::TkIDENTIFIER.new( 4, 1,  4, "x"),
      @TK::TkLPAREN    .new( 5, 1,  5, "("),
      @TK::TkRPAREN    .new( 6, 1,  6, ")"),
      @TK::TkSPACE     .new( 7, 1,  7, " "),
      @TK::TkEND       .new( 8, 1,  8, "end"),
      @TK::TkNL        .new(11, 1, 11, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize___END__
    tokens = RDoc::RubyLex.tokenize '__END__', nil

    expected = [
      @TK::TkEND_OF_SCRIPT.new(0, 1, 0, '__END__'),
      @TK::TkNL           .new(7, 1, 7, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_character_literal
    tokens = RDoc::RubyLex.tokenize "?\\", nil

    expected = [
      @TK::TkCHAR.new( 0, 1,  0, "?\\"),
      @TK::TkNL  .new( 2, 1,  2, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_def_heredoc
    tokens = RDoc::RubyLex.tokenize <<-'RUBY', nil
def x
  <<E
Line 1
Line 2
E
end
    RUBY

    expected = [
      @TK::TkDEF       .new( 0, 1,  0, 'def'),
      @TK::TkSPACE     .new( 3, 1,  3, ' '),
      @TK::TkIDENTIFIER.new( 4, 1,  4, 'x'),
      @TK::TkNL        .new( 5, 1,  5, "\n"),
      @TK::TkSPACE     .new( 6, 2,  0, '  '),
      @TK::TkHEREDOC   .new( 8, 2,  2,
                            %Q{<<E\nLine 1\nLine 2\nE}),
      @TK::TkNL        .new(27, 5, 28, "\n"),
      @TK::TkEND       .new(28, 6,  0, 'end'),
      @TK::TkNL        .new(31, 6, 28, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_hash_symbol
    tokens = RDoc::RubyLex.tokenize '{ class:"foo" }', nil

    expected = [
      @TK::TkLBRACE    .new( 0, 1,  0, '{'),
      @TK::TkSPACE     .new( 1, 1,  1, ' '),
      @TK::TkIDENTIFIER.new( 2, 1,  2, 'class'),
      @TK::TkSYMBOL    .new( 7, 1,  7, ':"foo"'),
      @TK::TkSPACE     .new(13, 1, 13, ' '),
      @TK::TkRBRACE    .new(14, 1, 14, '}'),
      @TK::TkNL        .new(15, 1, 15, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_hash_rocket
    tokens = RDoc::RubyLex.tokenize '{ :class => "foo" }', nil

    expected = [
      @TK::TkLBRACE    .new( 0, 1,  0, '{'),
      @TK::TkSPACE     .new( 1, 1,  1, ' '),
      @TK::TkSYMBOL    .new( 2, 1,  2, ':class'),
      @TK::TkSPACE     .new( 8, 1,  8, ' '),
      @TK::TkHASHROCKET.new( 9, 1,  9, '=>'),
      @TK::TkSPACE     .new(11, 1, 11, ' '),
      @TK::TkSTRING    .new(12, 1, 12, '"foo"'),
      @TK::TkSPACE     .new(17, 1, 17, ' '),
      @TK::TkRBRACE    .new(18, 1, 18, '}'),
      @TK::TkNL        .new(19, 1, 19, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_heredoc_CR_NL
    tokens = RDoc::RubyLex.tokenize <<-RUBY, nil
string = <<-STRING\r
Line 1\r
Line 2\r
  STRING\r
    RUBY

    expected = [
      @TK::TkIDENTIFIER.new( 0, 1,  0, 'string'),
      @TK::TkSPACE     .new( 6, 1,  6, ' '),
      @TK::TkASSIGN    .new( 7, 1,  7, '='),
      @TK::TkSPACE     .new( 8, 1,  8, ' '),
      @TK::TkHEREDOC   .new( 9, 1,  9,
                            %Q{<<-STRING\nLine 1\nLine 2\n  STRING}),
      @TK::TkSPACE     .new(44, 4, 45, "\r"),
      @TK::TkNL        .new(45, 4, 46, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_heredoc_call
    tokens = RDoc::RubyLex.tokenize <<-'RUBY', nil
string = <<-STRING.chomp
Line 1
Line 2
  STRING
    RUBY

    expected = [
      @TK::TkIDENTIFIER.new( 0, 1,  0, 'string'),
      @TK::TkSPACE     .new( 6, 1,  6, ' '),
      @TK::TkASSIGN    .new( 7, 1,  7, '='),
      @TK::TkSPACE     .new( 8, 1,  8, ' '),
      @TK::TkSTRING    .new( 9, 1,  9, %Q{"Line 1\nLine 2\n"}),
      @TK::TkDOT       .new(41, 4, 42, '.'),
      @TK::TkIDENTIFIER.new(42, 4, 43, 'chomp'),
      @TK::TkNL        .new(47, 4, 48, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_heredoc_indent
    tokens = RDoc::RubyLex.tokenize <<-'RUBY', nil
string = <<-STRING
Line 1
Line 2
  STRING
    RUBY

    expected = [
      @TK::TkIDENTIFIER.new( 0, 1,  0, 'string'),
      @TK::TkSPACE     .new( 6, 1,  6, ' '),
      @TK::TkASSIGN    .new( 7, 1,  7, '='),
      @TK::TkSPACE     .new( 8, 1,  8, ' '),
      @TK::TkHEREDOC   .new( 9, 1,  9,
                            %Q{<<-STRING\nLine 1\nLine 2\n  STRING}),
      @TK::TkNL        .new(41, 4, 42, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_heredoc_missing_end
    e = assert_raises RDoc::RubyLex::Error do
      RDoc::RubyLex.tokenize <<-'RUBY', nil
>> string1 = <<-TXT
>" That's swell
>" TXT
      RUBY
    end

    assert_equal 'Missing terminating TXT for string', e.message
  end

  def test_class_tokenize_heredoc_percent_N
    tokens = RDoc::RubyLex.tokenize <<-'RUBY', nil
a b <<-U
%N
U
    RUBY

    expected = [
      @TK::TkIDENTIFIER.new( 0, 1,  0, 'a'),
      @TK::TkSPACE     .new( 1, 1,  1, ' '),
      @TK::TkIDENTIFIER.new( 2, 1,  2, 'b'),
      @TK::TkSPACE     .new( 3, 1,  3, ' '),
      @TK::TkHEREDOC   .new( 4, 1,  4, %Q{<<-U\n%N\nU}),
      @TK::TkNL        .new(13, 3, 14, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_identifier_high_unicode
    tokens = RDoc::RubyLex.tokenize '𝖒', nil

    expected = @TK::TkIDENTIFIER.new(0, 1, 0, '𝖒')

    assert_equal expected, tokens.first
  end

  def test_class_tokenize_percent_1
    tokens = RDoc::RubyLex.tokenize 'v%10==10', nil

    expected = [
      @TK::TkIDENTIFIER.new(0, 1, 0, 'v'),
      @TK::TkMOD.new(       1, 1, 1, '%'),
      @TK::TkINTEGER.new(   2, 1, 2, '10'),
      @TK::TkEQ.new(        4, 1, 4, '=='),
      @TK::TkINTEGER.new(   6, 1, 6, '10'),
      @TK::TkNL.new(        8, 1, 8, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_percent_r
    tokens = RDoc::RubyLex.tokenize '%r[hi]', nil

    expected = [
      @TK::TkREGEXP.new( 0, 1,  0, '%r[hi]'),
      @TK::TkNL    .new( 6, 1, 6, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_percent_w
    tokens = RDoc::RubyLex.tokenize '%w[hi]', nil

    expected = [
      @TK::TkDSTRING.new( 0, 1,  0, '%w[hi]'),
      @TK::TkNL     .new( 6, 1, 6, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_percent_w_quote
    tokens = RDoc::RubyLex.tokenize '%w"hi"', nil

    expected = [
      @TK::TkDSTRING.new( 0, 1,  0, '%w"hi"'),
      @TK::TkNL     .new( 6, 1, 6, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_regexp
    tokens = RDoc::RubyLex.tokenize "/hay/", nil

    expected = [
      @TK::TkREGEXP.new( 0, 1,  0, "/hay/"),
      @TK::TkNL    .new( 5, 1,  5, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_regexp_options
    tokens = RDoc::RubyLex.tokenize "/hAY/i", nil

    expected = [
      @TK::TkREGEXP.new( 0, 1,  0, "/hAY/i"),
      @TK::TkNL    .new( 6, 1,  6, "\n"),
    ]

    assert_equal expected, tokens

    tokens = RDoc::RubyLex.tokenize "/hAY/ix", nil

    expected = [
      @TK::TkREGEXP.new( 0, 1,  0, "/hAY/ix"),
      @TK::TkNL    .new( 7, 1,  7, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_regexp_backref
    tokens = RDoc::RubyLex.tokenize "/[csh](..) [csh]\\1 in/", nil

    expected = [
      @TK::TkREGEXP.new( 0, 1,  0, "/[csh](..) [csh]\\1 in/"),
      @TK::TkNL    .new(22, 1, 22, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_regexp_escape
    tokens = RDoc::RubyLex.tokenize "/\\//", nil

    expected = [
      @TK::TkREGEXP.new( 0, 1,  0, "/\\//"),
      @TK::TkNL    .new( 4, 1,  4, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_string
    tokens = RDoc::RubyLex.tokenize "'hi'", nil

    expected = [
      @TK::TkSTRING.new( 0, 1,  0, "'hi'"),
      @TK::TkNL    .new( 4, 1,  4, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_string_with_escape
    tokens = RDoc::RubyLex.tokenize <<'RUBY', nil
[
  '\\',
  '\'',
  "'",
  "\'\"\`",
  "\#",
  "\#{}",
  "#",
  "#{}",
  /'"/,
  /\'\"/,
  /\//,
  /\\/,
  /\#/,
  /\#{}/,
  /#/,
  /#{}/
]
RUBY

    expected = [
      @TK::TkLBRACK .new(  0,  1,   0, "["),
      @TK::TkNL     .new(  1,  1,   1, "\n"),
      @TK::TkSPACE  .new(  2,  2,   0, "  "),
      @TK::TkSTRING .new(  4,  2,   2, "'\\\\'"),
      @TK::TkCOMMA  .new(  8,  2,   6, ","),
      @TK::TkNL     .new(  9,  2,   2, "\n"),
      @TK::TkSPACE  .new( 10,  3,   0, "  "),
      @TK::TkSTRING .new( 12,  3,   2, "'\\''"),
      @TK::TkCOMMA  .new( 16,  3,   6, ","),
      @TK::TkNL     .new( 17,  3,  10, "\n"),
      @TK::TkSPACE  .new( 18,  4,   0, "  "),
      @TK::TkSTRING .new( 20,  4,   2, "\"'\""),
      @TK::TkCOMMA  .new( 23,  4,   5, ","),
      @TK::TkNL     .new( 24,  4,  18, "\n"),
      @TK::TkSPACE  .new( 25,  5,   0, "  "),
      @TK::TkSTRING .new( 27,  5,   2, "\"\\'\\\"\\`\""),
      @TK::TkCOMMA  .new( 35,  5,  10, ","),
      @TK::TkNL     .new( 36,  5,  25, "\n"),
      @TK::TkSPACE  .new( 37,  6,   0, "  "),
      @TK::TkSTRING .new( 39,  6,   2, "\"\\#\""),
      @TK::TkCOMMA  .new( 43,  6,   6, ","),
      @TK::TkNL     .new( 44,  6,  37, "\n"),
      @TK::TkSPACE  .new( 45,  7,   0, "  "),
      @TK::TkSTRING .new( 47,  7,   2, "\"\\\#{}\""),
      @TK::TkCOMMA  .new( 53,  7,   8, ","),
      @TK::TkNL     .new( 54,  7,  45, "\n"),
      @TK::TkSPACE  .new( 55,  8,   0, "  "),
      @TK::TkSTRING .new( 57,  8,   2, "\"#\""),
      @TK::TkCOMMA  .new( 60,  8,   5, ","),
      @TK::TkNL     .new( 61,  8,  55, "\n"),
      @TK::TkSPACE  .new( 62,  9,   0, "  "),
      @TK::TkDSTRING.new( 64,  9,   2, "\"\#{}\""),
      @TK::TkCOMMA  .new( 69,  9,   7, ","),
      @TK::TkNL     .new( 70,  9,  62, "\n"),
      @TK::TkSPACE  .new( 71, 10,   0, "  "),
      @TK::TkREGEXP .new( 73, 10,   2, "/'\"/"),
      @TK::TkCOMMA  .new( 77, 10,   6, ","),
      @TK::TkNL     .new( 78, 10,  71, "\n"),
      @TK::TkSPACE  .new( 79, 11,   0, "  "),
      @TK::TkREGEXP .new( 81, 11,   2, "/\\'\\\"/"),
      @TK::TkCOMMA  .new( 87, 11,   8, ","),
      @TK::TkNL     .new( 88, 11,  79, "\n"),
      @TK::TkSPACE  .new( 89, 12,   0, "  "),
      @TK::TkREGEXP .new( 91, 12,   2, "/\\//"),
      @TK::TkCOMMA  .new( 95, 12,   6, ","),
      @TK::TkNL     .new( 96, 12,  89, "\n"),
      @TK::TkSPACE  .new( 97, 13,   0, "  "),
      @TK::TkREGEXP .new( 99, 13,   2, "/\\\\/"),
      @TK::TkCOMMA  .new(103, 13,   6, ","),
      @TK::TkNL     .new(104, 13,  97, "\n"),
      @TK::TkSPACE  .new(105, 14,   0, "  "),
      @TK::TkREGEXP .new(107, 14,   2, "/\\#/"),
      @TK::TkCOMMA  .new(111, 14,   6, ","),
      @TK::TkNL     .new(112, 14, 105, "\n"),
      @TK::TkSPACE  .new(113, 15,   0, "  "),
      @TK::TkREGEXP .new(115, 15,   2, "/\\\#{}/"),
      @TK::TkCOMMA  .new(121, 15,   8, ","),
      @TK::TkNL     .new(122, 15, 113, "\n"),
      @TK::TkSPACE  .new(123, 16,   0, "  "),
      @TK::TkREGEXP .new(125, 16,   2, "/#/"),
      @TK::TkCOMMA  .new(128, 16,   5, ","),
      @TK::TkNL     .new(129, 16, 123, "\n"),
      @TK::TkSPACE  .new(130, 17,   0, "  "),
      @TK::TkDREGEXP.new(132, 17,   2, "/\#{}/"),
      @TK::TkNL     .new(137, 17,   7, "\n"),
      @TK::TkRBRACK .new(138, 18,   0, "]"),
      @TK::TkNL     .new(139, 18, 138, "\n")
    ]

    assert_equal expected, tokens
  end

  def test_class_tokenize_string_escape
    tokens = RDoc::RubyLex.tokenize '"\\n"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\n\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\r"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\r\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\f"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\f\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\\\"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\\\\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\t"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\t\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\v"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\v\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\a"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\a\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\e"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\e\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\b"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\b\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\s"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\s\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\d"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\d\""), tokens.first

  end

  def test_class_tokenize_string_escape_control
    tokens = RDoc::RubyLex.tokenize '"\\C-a"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\C-a\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\c\\a"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\c\\a\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\C-\\M-a"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\C-\\M-a\""), tokens.first
  end

  def test_class_tokenize_string_escape_meta
    tokens = RDoc::RubyLex.tokenize '"\\M-a"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\M-a\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\M-\\C-a"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\M-\\C-a\""), tokens.first
  end

  def test_class_tokenize_string_escape_hexadecimal
    tokens = RDoc::RubyLex.tokenize '"\\x0"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\x0\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\x00"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\x00\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\x000"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\x000\""), tokens.first
  end

  def test_class_tokenize_string_escape_octal
    tokens = RDoc::RubyLex.tokenize '"\\0"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\0\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\00"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\00\""), tokens.first

    tokens = RDoc::RubyLex.tokenize '"\\000"', nil
    assert_equal @TK::TkSTRING.new( 0, 1,  0, "\"\\000\""), tokens.first
  end

  def test_class_tokenize_symbol
    tokens = RDoc::RubyLex.tokenize 'scope module: :v1', nil

    expected = [
      @TK::TkIDENTIFIER.new( 0, 1,  0, 'scope'),
      @TK::TkSPACE     .new( 5, 1,  5, ' '),
      @TK::TkIDENTIFIER.new( 6, 1,  6, 'module'),
      @TK::TkCOLON     .new(12, 1, 12, ':'),
      @TK::TkSPACE     .new(13, 1, 13, ' '),
      @TK::TkSYMBOL    .new(14, 1, 14, ':v1'),
      @TK::TkNL        .new(17, 1, 17, "\n"),
    ]

    assert_equal expected, tokens
  end

  def test_unary_minus
    ruby_lex = RDoc::RubyLex.new("-1", nil)
    assert_equal("-1", ruby_lex.token.value)

    ruby_lex = RDoc::RubyLex.new("a[-2]", nil)
    2.times { ruby_lex.token } # skip "a" and "["
    assert_equal("-2", ruby_lex.token.value)

    ruby_lex = RDoc::RubyLex.new("a[0..-12]", nil)
    4.times { ruby_lex.token } # skip "a", "[", "0", and ".."
    assert_equal("-12", ruby_lex.token.value)

    ruby_lex = RDoc::RubyLex.new("0+-0.1", nil)
    2.times { ruby_lex.token } # skip "0" and "+"
    assert_equal("-0.1", ruby_lex.token.value)
  end

  def test_rational_imaginary_tokenize
    tokens = RDoc::RubyLex.tokenize '1.11r + 2.34i + 5.55ri', nil

    expected = [
      @TK::TkRATIONAL .new( 0, 1,  0, '1.11r'),
      @TK::TkSPACE    .new( 5, 1,  5, ' '),
      @TK::TkPLUS     .new( 6, 1,  6, '+'),
      @TK::TkSPACE    .new( 7, 1,  7, ' '),
      @TK::TkIMAGINARY.new( 8, 1,  8, '2.34i'),
      @TK::TkSPACE    .new(13, 1, 13, ' '),
      @TK::TkPLUS     .new(14, 1, 14, '+'),
      @TK::TkSPACE    .new(15, 1, 15, ' '),
      @TK::TkIMAGINARY.new(16, 1, 16, '5.55ri'),
      @TK::TkNL       .new(22, 1, 22, "\n"),
    ]

    assert_equal expected, tokens
  end

end

