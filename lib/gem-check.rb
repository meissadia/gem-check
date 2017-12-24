require 'rubygems'
require 'ostruct'
require 'gems'
require 'terminal-table'
require 'open-uri'
require 'json'
require 'date'
require_relative 'gem-check/version'
require_relative 'gem-check/cli'
require_relative 'gem-check/helpers'

module GemCheck

  class Checker
    URL_GEMCHECK_INFO_JSON = 'https://rubygems.org/api/v1/versions/gem-check.json'
    INFO_FILENAME          = 'gem-check.json'

    REPORT_HEADINGS = ['Gem Name', 'Gem Version', 'Version DLs', 'All DLs']
    COL_NAME = 0 # Gem Name
    COL_VER  = 1 # Version
    COL_VDL  = 2 # Version DLs
    COL_TDL  = 3 # Total DLs

    def initialize(args=[])
      @new_downloads    = 0
      @update_version   = nil
      @current_stats    = nil
      @previous_stats   = []
      @previous_date    = Time.now
      @f_previous_stats = File.join(Dir.home, INFO_FILENAME)
      @args = args
    end

    def check
      read_previous_info
      print_table(build_table)
      store_new_info unless @args.include?('-f')
    end

    # Read stored gem info
    def read_previous_info
      return unless File.exist? @f_previous_stats
      f = File.read(@f_previous_stats)
      @previous_date  = Time.parse(f.lines.first.chomp) || nil
      @previous_stats = []
      f.lines.drop(1).each { |line| @previous_stats << clean_stat_line(line)}
      @previous_stats
    end

    def build_table
      rows  = current_gem_info.sort!{|a, b| b[2].to_i <=> a[2].to_i}
      rows  = add_new_download_info(rows)
      table = Terminal::Table.new(rows: rows)
      table.title    = header_string
      table.headings = REPORT_HEADINGS
      [1  ].each{ |col| table.align_column(col, :left)  }
      [2,3].each{ |col| table.align_column(col, :center) }
      table
    end

    # Display
    def print_table(table)
      puts "\n#{table}\n\n"
    end

    # Save newest gem info to file @f_previous_stats
    def store_new_info
      File.open(@f_previous_stats, 'w') do |file|
        file.write "#{current_date_string}\n"
        @current_stats.each do |row|
          row.each_with_index do |col, idx|
            row[idx] = decommafy(row[idx]).to_i if idx > 1
          end
          file.write row.to_json + "\n"
        end
      end
    end
  end
end
