require 'test/unit'
require 'axlsx.rb'

class TestWorksheet < Test::Unit::TestCase
  def setup    
    p = Axlsx::Package.new
    @ws = p.workbook.add_worksheet
  end

  def test_pn
    assert_equal(@ws.pn, "worksheets/sheet1.xml")
    ws = @ws.workbook.add_worksheet
    assert_equal(ws.pn, "worksheets/sheet2.xml")
  end

  def test_rels_pn
    assert_equal(@ws.rels_pn, "worksheets/_rels/sheet1.xml.rels")
    ws = @ws.workbook.add_worksheet
    assert_equal(ws.rels_pn, "worksheets/_rels/sheet2.xml.rels")
  end

  def test_rId
    assert_equal(@ws.rId, "rId1")
    ws = @ws.workbook.add_worksheet
    assert_equal(ws.rId, "rId2")
  end
  
  def test_index
    assert_equal(@ws.index, @ws.workbook.worksheets.index(@ws))
  end

  def test_add_row
    assert(@ws.rows.empty?, "sheet has no rows by default")
    r = @ws.add_row([1,2,3])
    assert_equal(@ws.rows.size, 1, "add_row adds a row")
    assert_equal(@ws.rows.first, r, "the row returned is the row added")
  end

  def test_add_chart
    assert(@ws.workbook.charts.empty?, "the sheet's workbook should not have any charts by default")
    @ws.add_chart Axlsx::Pie3DChart
    assert_equal(@ws.workbook.charts.size, 1, "add_chart adds a chart to the workbook")
  end

  def test_drawing
    assert @ws.drawing.is_a? Axlsx::Drawing
  end

  
  def test_to_xml
    schema = Nokogiri::XML::Schema(File.open(Axlsx::SML_XSD))
    doc = Nokogiri::XML(@ws.to_xml)
    errors = []
    schema.validate(doc).each do |error|
      errors.push error
      puts error.message
    end
    assert(errors.empty?, "error free validation")
  end

  def test_relationships
    assert(@ws.relationships.empty?, "No Drawing relationship until you add a chart")
    c = @ws.add_chart Axlsx::Pie3DChart
    assert_equal(@ws.relationships.size, 1, "adding a chart creates the relationship")
    c = @ws.add_chart Axlsx::Pie3DChart
    assert_equal(@ws.relationships.size, 1, "multiple charts still only result in one relationship")
  end

  
  def test_update_auto_with_data
    small = @ws.workbook.styles.add_style(:sz=>2)
    big = @ws.workbook.styles.add_style(:sz=>10)
    @ws.add_row ["chasing windmills", "penut"], :style=>small
    assert(@ws.auto_fit_data.size == 2, "a data item for each column")
    assert_equal(@ws.auto_fit_data[0], {:sz=>2,:longest=>"chasing windmills"}, "adding a row updates auto_fit_data if the product of the string length and font is greater for the column")
    @ws.add_row ["mule"], :style=>big
    assert_equal(@ws.auto_fit_data[0], {:sz=>10,:longest=>"mule"}, "adding a row updates auto_fit_data if the product of the string length and font is greater for the column")
  end

  def test_auto_width
    assert(@ws.send(:auto_width, {:sz=>11, :longest=>"fisheries"}) > @ws.send(:auto_width, {:sz=>11, :longest=>"fish"}), "longer strings get a longer auto_width at the same font size")
    assert(@ws.send(:auto_width, {:sz=>12, :longest=>"fish"}) > @ws.send(:auto_width, {:sz=>11, :longest=>"fish"}), "larger font size gets a longer auto_width using the same text")
  end

end