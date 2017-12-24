module GemCheck
  class Checker
    private

    # File I/O
    def clean_stat_line(line)
      chars_to_filter = %w(\\\" [ ])
      line.chomp!
      chars_to_filter.each { |c| line.delete!(c) }
      line.split(',')
    end

    def current_date_string
      Time.now.strftime("%b %d, %H:%M:%S")
    end

    # Gems API
    def current_gem_info
      @current_stats = []
      Gems.gems.map do |x|
        x = OpenStruct.new(x)
        val = [x.name, x.version, commafy(x.version_downloads), commafy(x.downloads)]
        @current_stats << val
        val
      end
    end

    # Features
    def add_new_download_info(latest_info)
      return latest_info if @previous_stats.empty?
      latest_info.map do |row|
        prev_info = search_by_column(@previous_stats, COL_NAME, row[COL_NAME])
        prev_info = search_by_column(prev_info,       COL_VER,  row[COL_VER])
        return row if prev_info.empty?
        prev_info = prev_info.first
        calc_new_downloads(COL_TDL, row, prev_info)
        calc_new_downloads(COL_VDL, row, prev_info)
        row
      end
    end

    def calc_new_downloads(idx, row, info)
      new_dls = decommafy(row[idx]).to_i - decommafy(info[idx]).to_i
      @new_downloads += new_dls
      row[idx] = new_dls > 0 ? "#{row[idx]} ( +#{commafy(new_dls)} )" : row[idx]
    end

    # Utils
    def search_by_column(table, column, search_s)
      return table if table.empty?
      table.select{ |r| r[column].eql?(search_s) }
    end

    # Maintanence
    def update_available?
      versions = open(URL_GEMCHECK_INFO_JSON).read
      @update_version = JSON.parse(versions, object_class: OpenStruct).first.number
      @update_version > GemCheck::VERSION
    end



  end
end