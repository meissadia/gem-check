require 'rubygems'
require 'ostruct'
require 'gems'
require 'terminal-table'
require_relative 'version'

module GemCheck
  def print_table
    rows = Gems.gems.map do |x|
      x = OpenStruct.new(x)
      [x.name, x.version, x.version_downloads, x.downloads]
    end
    rows.sort!{|a, b| b[2] <=> a[2]}

    table = Terminal::Table.new(rows: rows)
    table.headings = ['Gem Name', 'Version', 'Downloads', 'Total']
    [1,2,3].each{ |col| table.align_column(col, :center) }
    puts table
  end
end
