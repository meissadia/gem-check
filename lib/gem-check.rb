require 'rubygems'
require 'ostruct'
require 'gems'
require 'terminal-table'
require 'open-uri'
require 'json'
require 'date'
require_relative 'version'

module GemCheck
  HEADINGS = ['Gem Name', 'Version', 'Downloads', 'Total', 'New DLs']
  C_NAME = 0
  C_VER  = 1
  C_VDL  = 2
  C_TDL  = 3
  C_NDL  = 4
  @@update_version = nil
  @@current_stats  = nil
  @@previous_stats = []
  @@previous_date  = Time.now
  @@f_previous_stats = File.join Dir.home, 'gem-check.json'

  def gem_check

    read_previous_info
    print_header
    print_table
    # store_gem_info
  end

  def print_header
    puts
    puts "#{version_string}#{update_status_string}"
    puts "Current: #{current_date_string}#{last_run}"
  end

  def commafy(x)
    i,d = x.to_s.split('.')
    i.gsub(/(\d)(?=\d{3}+$)/,'\\1,') + (d ? ('.'+d) : '')
  end

  def decommafy(x)
    return x unless x.class.eql? String
    x.delete(',')
  end

  def current_gem_info
    @@current_stats = []
    Gems.gems.map do |x|
      x = OpenStruct.new(x)
      val = [x.name, x.version, commafy(x.version_downloads), commafy(x.downloads), 0]
      @@current_stats << val
      val
    end
  end

  def build_table
    rows  = current_gem_info.sort!{|a, b| b[2].to_i <=> a[2].to_i}
    rows  = calculate_new_downloads(rows)
    table = Terminal::Table.new(rows: rows)
    table.headings = GemCheck::HEADINGS
    [1  ].each{ |col| table.align_column(col, :left)  }
    [2,3].each{ |col| table.align_column(col, :right) }
    [4  ].each{ |col| table.align_column(col, :center) }
    table
  end

  def version_string
    "GemCheck v#{GemCheck::VERSION}"
  end

  def calculate_new_downloads(latest_info)
    return latest_info if @@previous_stats.empty?
    latest_info.map do |row|
      prev_info = search_by_column(@@previous_stats, C_NAME, row[C_NAME])
      prev_info = search_by_column(prev_info,        C_VER,  row[C_VER])
      return row if prev_info.empty?
      prev_info = prev_info.first
      row[C_NDL] = decommafy(row[C_TDL]).to_i - decommafy(prev_info[C_TDL]).to_i
      row
    end

  end

  def search_by_column(array, column, search_string)
    # puts "Col: #{column}, Query: #{search_string}\nArray: \n\t#{array}\n\n"
    return array if array.empty?
    array.select{ |r| r[column].eql? search_string }
  end

  def update_available?
    versions = open('https://rubygems.org/api/v1/versions/gem-check.json').read
    @@update_version = JSON.parse(versions, object_class: OpenStruct).first.number
    @@update_version != GemCheck::VERSION
  end

  def update_status_string
    update_available? ? " [ v#{@@update_version} available! ]" : nil
  end

  def current_date_string
    Time.now.strftime("%b %d, %H:%M:%S")
  end

  def print_table
    puts build_table
    puts
  end

  # Store latest gem info
  def store_gem_info
    File.open(@@f_previous_stats, 'w') do |file|
      file.write "#{current_date_string}\n"
      @@current_stats.each do |row|
        row.each_with_index do |col, idx|
          row[idx] = decommafy(row[idx]).to_i if idx > 1
        end
        file.write row.to_json + "\n"
      end
    end
  end

  # Read stored gem info
  def read_previous_info
    return unless File.exist? @@f_previous_stats
    f = File.read(@@f_previous_stats)
    @@previous_date = Time.parse(f.lines.first.chomp) || nil
    @@previous_stats = []
    f.lines.drop(1).each { |x| @@previous_stats << x.chomp.delete("\\\"").delete('[').delete(']').split(',').to_a}
  end

  # adapted from https://stackoverflow.com/a/195894
  def last_run
    t_diff = @@previous_date ? (Time.now - @@previous_date).to_i : nil
    msg =
      case t_diff
      when nil then nil
      when 0 then 'just now'
      when 1 then 'a second ago'
      when 2..59 then t_diff.to_s+' seconds ago'
      when 60..119 then 'a minute ago' #120 = 2 minutes
      when 120..3540 then (t_diff/60).to_i.to_s+' minutes ago'
      when 3541..7100 then 'an hour ago' # 3600 = 1 hour
      when 7101..82800 then ((t_diff+99)/3600).to_i.to_s+' hours ago'
      when 82801..172000 then 'a day ago' # 86400 = 1 day
      when 172001..518400 then ((t_diff+800)/(60*60*24)).to_i.to_s+' days ago'
      when 518400..1036800 then 'a week ago'
      else ((t_diff+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
      end

    msg ? " | Last run: #{msg}" : ''
  end


end
