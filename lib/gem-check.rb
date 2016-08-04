require 'rubygems'
require 'ostruct'
require 'gems'
require 'terminal-table'
require_relative 'version'

module GemCheck
  HEADINGS = ['Gem Name', 'Version', 'Downloads', 'Total']

  def commafy(x)
    i,d = x.to_s.split('.')
    i.gsub(/(\d)(?=\d{3}+$)/,'\\1,') + (d ? ('.'+d) : '')
  end

  def gem_info
    Gems.gems.map do |x|
      x = OpenStruct.new(x)
      [x.name, x.version, commafy(x.version_downloads), commafy(x.downloads)]
    end
  end

  def build_table
    rows  = gem_info.sort!{|a, b| b[2].to_i <=> a[2].to_i}
    table = Terminal::Table.new(rows: rows)
    table.headings = GemCheck::HEADINGS
    [1].each{ |col| table.align_column(col, :center) }
    [2,3].each{ |col| table.align_column(col, :right) }
    table
  end

  def print_table
    puts
    puts build_table
    puts
  end
end
