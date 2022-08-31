# frozen_string_literal: true

require 'old_helper'
require 'peddler/flat_file_parser'

class TestPeddlerFlatFileParser < MiniTest::Test
  def test_parsing_data
    body = build_body("Feed Processing Summary:\n\tNumber of records processed\t\t11006\n\tNumber of records successful\t\t11006\n\noriginal-record-number\tsku\terror-code\terror-type\terror-message\n1822\t85da472e-ba6c-11e3-95af-002590a74356\t5000\tWarning\tThe update for Sku '85da472e-ba6c-11e3-95af-002590a74356' was skipped because it is identical to the update in feed '9518995390'.\n",
                      encoding: Encoding::ASCII_8BIT)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), 'ISO-8859-1')
    assert_kind_of CSV::Table, parser.parse
  end

  def test_parsing_data_a_line_at_a_time
    body = build_body("Feed Processing Summary:\n\tNumber of records processed\t\t11006\n\tNumber of records successful\t\t11006\n\noriginal-record-number\tsku\terror-code\terror-type\terror-message\n1822\t85da472e-ba6c-11e3-95af-002590a74356\t5000\tWarning\tThe update for Sku '85da472e-ba6c-11e3-95af-002590a74356' was skipped because it is identical to the update in feed '9518995390'.\n",
                      encoding: Encoding::ASCII_8BIT)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), 'ISO-8859-1')
    counter = 0
    parser.parse { counter += 1 }
    assert_predicate counter, :positive?
  end

  def test_the_work_around_empty_rows
    body = build_body("Feed Processing Summary:\n\tNumber of records processed\t\t2\n\tNumber of records successful\t\t2\n\nfoo\tbar\n1\ta\n\n2\tb\n",
                      encoding: Encoding::ASCII_8BIT)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), 'ISO-8859-1')
    assert_equal 3, parser.parse.count
  end

  def test_summary
    body = build_body("Feed Processing Summary:\n\tNumber of records processed\t\t11006\n\tNumber of records successful\t\t11006\n\noriginal-record-number\tsku\terror-code\terror-type\terror-message\n1822\t85da472e-ba6c-11e3-95af-002590a74356\t5000\tWarning\tThe update for Sku '85da472e-ba6c-11e3-95af-002590a74356' was skipped because it is identical to the update in feed '9518995390'.\n",
                      encoding: Encoding::ASCII_8BIT)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), 'ISO-8859-1')
    refute_empty parser.records_count
  end

  def test_summary_of_non_english_reports
    body = build_body("Riepilogo elaborazione feed:\n\tNumero record elaborati\t\t1\n\tNumero record elaborati con successo\t\t1\n\n",
                      encoding: 'Cp1252')
    parser = Peddler::FlatFileParser.new(build_mock_response(body), 'ISO-8859-1')
    refute_empty parser.records_count
  end

  def test_validates
    body = build_body("Feed Processing Summary:\n\tNumber of records processed\t\t11006\n\tNumber of records successful\t\t11006\n\noriginal-record-number\tsku\terror-code\terror-type\terror-message\n1822\t85da472e-ba6c-11e3-95af-002590a74356\t5000\tWarning\tThe update for Sku '85da472e-ba6c-11e3-95af-002590a74356' was skipped because it is identical to the update in feed '9518995390'.\n",
                      encoding: Encoding::ASCII_8BIT)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), 'ISO-8859-1')
    assert_predicate parser, :valid?
  end

  def test_handling_reports_without_a_summary
    response = OpenStruct.new(body: "Foo\nBar\n")
    parser = Peddler::FlatFileParser.new(response, 'ISO-8859-1')
    refute_empty parser.content
  end

  def test_encoding_if_passed_in_header
    body = build_body("Foo\nfür\n", encoding: Encoding::UTF_8)
    parser = Peddler::FlatFileParser.new(build_mock_response(body,
                                                             charset: 'UTF-8'),
                                         Encoding::CP1252)
    assert_equal 'für', parser.parse[0]['Foo']
  end

  def test_handling_japanese_flat_files
    body = build_body("Foo\nこんにちは\n", encoding: Encoding::SHIFT_JIS)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), Encoding::WINDOWS_31J)
    assert_equal 'こんにちは', parser.parse[0]['Foo']
  end

  def test_handling_japanese_curly_braces
    body = build_body("Foo\n〝\n", encoding: Encoding::WINDOWS_31J)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), Encoding::WINDOWS_31J)
    assert_equal '〝', parser.parse[0]['Foo']
  end

  def test_handling_latin_1_flat_files
    body = build_body("Foo\n™\n", encoding: 'Cp1252')
    parser = Peddler::FlatFileParser.new(build_mock_response(body), Encoding::CP1252)
    assert_equal '™', parser.parse['Foo'][0]
  end

  def test_handling_undefined_characters
    body = +"Foo\n\xFF\n"
    body.force_encoding(Encoding::ASCII_8BIT)
    parser = Peddler::FlatFileParser.new(build_mock_response(body), Encoding::ASCII_8BIT)
    assert_equal '�', parser.parse['Foo'][0]
  end

  def test_handling_utf8_flat_files
    body = "Foo\nfür\n"
    parser = Peddler::FlatFileParser.new(build_mock_response(body, ascii: false), Encoding::CP1252)
    assert_equal 'für', parser.parse['Foo'][0]
  end

  def test_chinese_headers
    body = "商品名称	商品描述	商品编码	卖家 SKU	价格	数量	开售日期	不适用项目	是否为商城中的商品	商品编码类型	不适用项目	商品备注	商品状况	不适用项目	不适用项目	不适用项目	ASIN1	不适用项目	不适用项目	国际配送	加急配送	不适用项目	商品编码	不适用项目	添加-删除	等待购买数量	配送渠道	企业商品价格	数量折扣价格类型	数量下限 1	数量折扣价格 1	数量下限 2	数量折扣价格 2	数量下限 3	数量折扣价格 3	数量下限 4	数量折扣价格 4	数量下限 5	数量折扣价格 5	卖家配送组
    Waterproof Sunshade Cover (180 * 180, Blue)	Material: Waterproof and UV resistant Oxford cloth <br><br> Color: green black blue <br><br> Product Size: <br> <br> 120 * 120CM weight 210g <br> <br> 150 * 150CM weight 290g <br><br> 180 * 180CM weight 380g <br><br> 200 * 200CM weight 460g	0645YNJ5NZ9	04-AFWM-8QDS	20.32	10	15/04/2020 15:15:46 BST		y	4			11				B2884WQWZY						4716528214404			0	DEFAULT				Migrated Template
    Cover Rain And Snow Cover (242 * 160 * 100)	Color: green can be customized <br><br> Fabric main component content: waterproof 210D Oxford cloth <br><br> Dimensions: length * width * height cm <br><br> size and weight: <br><br> 242 * 162 * 100cm weight 950g <br><br> 308 * 138 * 89cm weight 950g <br><br> 213 * 132 * 70cm weight 590g <br><br> 180 * 120 * 70cm weight 500g <br><br> 126 * 126 * 74cm weight 430g <br><br> 123 * 61 * 72cm weight 280g <br><br> 115 * 115 * 70cm weight 280g <br><br> 315 * 160 * 70cm weight 910g <br><br> 230 * 165 * 70cm weight 720g <br><br> 210 * 140 * 70cm weight 600g <br><br> 210 * 110 * 70cm weight 540g <br><br> 205 * 104 * 71cm weight 510g <br><br> 170 * 71 * 94cm weight 450g <br><br> 160 * 160 * 70cm weight 560g <br><br> 150 * 150 * 70cm weight 510g <br><br> 152 * 104 * 71cm weight 420g <br><br> 250 * 250 * 90cm weight 1190g	0416XWWK0U5	02-5QLY-0EFL	35.29	10	16/04/2020 15:01:43 BST		y	4			11				B0234CWWCC						4714528214534			0	DEFAULT													Migrated Template"
    parser = Peddler::FlatFileParser.new(build_mock_response(body, ascii: false, charset: 'utf8'), Encoding::CP1252)
    assert parser.parse[0]['卖家 SKU']
  end

  private

  def build_body(str, encoding:)
    str.dup.encode(encoding)
  end

  def build_mock_response(body, ascii: true, charset: nil)
    body.force_encoding(Encoding::ASCII_8BIT) if ascii
    headers = {
      'Content-MD5' => Digest::MD5.base64digest(body)
    }
    headers['Content-Type'] = "text/plain;charset=#{charset}" if charset

    OpenStruct.new(body: body, headers: headers)
  end
end
