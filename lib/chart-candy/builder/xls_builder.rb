require 'spreadsheet'

class ChartCandy::Builder::XlsBuilder
  attr_reader :current_row, :current_column, :workbook

  def self.chart_to_xls(chart)
    xls = self.new(chart)
    xls.generate

    return xls.workbook
  end

  def initialize(chart)
    @chart = chart
    @workbook = Spreadsheet::Workbook.new
    @sheet = @workbook.create_worksheet
    @formats = build_formats

    @current_row = -1
    @current_row_format = :normal
    @current_column = 0

    @columns_width = []
    @max_column_width = 50
    @default_column_width = 10
  end

  def add_align_right_formats(formats)
    align_right = {}

    formats.each do |k,origin|
      new_format = origin.dup
      new_format.horizontal_align = :right

      align_right["#{k}_right".to_sym] = new_format
    end

    formats.merge! align_right
  end

  def build_formats
    f = {}

    f[:h1] = Spreadsheet::Format.new(weight: :bold,    size: 16,  horizontal_align: :left, vertical_align: :middle)
    f[:h2] = Spreadsheet::Format.new(weight: :normal,  size: 12,  horizontal_align: :left, vertical_align: :middle)
    f[:h3] = Spreadsheet::Format.new(weight: :normal,  size: 9,   horizontal_align: :left, vertical_align: :middle)
    f[:h4] = Spreadsheet::Format.new(weight: :bold,    size: 8,   horizontal_align: :left, vertical_align: :middle)
    f[:th] = Spreadsheet::Format.new(weight: :bold,    size: 8,   horizontal_align: :center, vertical_align: :middle, pattern_fg_color: :xls_color_19, pattern: 1)
    f[:th_foot] = Spreadsheet::Format.new(weight: :bold, size: 8, horizontal_align: :left, vertical_align: :middle, pattern_fg_color: :xls_color_19, pattern: 1)
    f[:normal] = Spreadsheet::Format.new(size: 8, horizontal_align: :left , vertical_align: :middle)

    add_align_right_formats f

    return f
  end

  def cell(content=nil, options={})
    options.reverse_merge! format: nil, nature: :text

    row_obj = @sheet.row(current_row)

    row_obj.set_format current_column, @formats[options[:format]] if options[:format]
    set_cell_format options[:nature]
    row_obj.height = row_obj.format(0).font.size * 1.6

    parsed_content = format_data(content)

    @sheet[current_row, current_column] = parsed_content

    @columns_width[current_column] = parsed_content.to_s.length if @columns_width[current_column].to_i < parsed_content.to_s.length

    @current_column += 1
  end

  def format_data(data)
    case
      when data.is_a?(Time) then data.strftime('%d-%m-%Y')
      else data
    end
  end

  def generate
    header

    case @chart[:nature]
      when 'line' then generate_chart_line_table
      when 'donut' then generate_chart_donut_table
    end

    set_columns_width
  end

  def generate_chart_line_table
    row @chart[:axis][:x][:label], :th

    @chart[:lines].map { |l| cell l[:label] }

    @chart[:lines][0][:data].each_with_index do |l,i|
      row

      cell l[:x], nature: @chart[:axis][:x][:nature]

      @chart[:lines].each { |line| cell line[:data][i][:y], nature: @chart[:axis][:y][:nature] }
    end

    row @chart[:lines][0][:total][:label], :th_foot

    @chart[:lines].map { |l| cell l[:total][:value], nature: :number }
  end

  def generate_chart_donut_table
    row [@chart[:label], @chart[:value]], :th

    @chart[:slices].map { |s| row [s[:label], s[:value]] }

    row [@chart[:total][:label], @chart[:total][:value]], :th_foot
  end

  def header
    row @chart[:title], :h1
    row @chart[:subtitle], :h2 if @chart[:subtitle]
    row @chart[:period], :h3 if @chart[:period]

    reset_columns_width

    skip_row
  end

  def reset_columns_width
    @columns_width = Array.new(@columns_width.length, @default_column_width)
  end

  def row(data=[], format = :normal)
    @current_column = 0
    @current_row += 1

    @sheet.row(current_row).default_format = @formats[format]
    @current_row_format = format

    [data].flatten.each { |d| cell(d) }
  end

  def set_cell_format(nature)
    if nature == :number
      f = "#{@current_row_format}_right".gsub('right_right', 'right').to_sym

      @sheet.row(current_row).set_format(current_column, @formats[f])
    end
  end

  def set_columns_width
    @columns_width.each_with_index do |c,i|
      @sheet.column(i).width = (c.to_i < @default_column_width) ? @default_column_width : c.to_i
    end
  end

  def skip_row
    @current_row += 1
  end
end
