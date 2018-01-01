module GemCheck
  class Checker
    def self.show_help
      puts
      puts "GemCheck v#{GemCheck::VERSION} - Help"
      puts "\n  Flags:\n"
      puts "    -f   Don't save the updated stats for this run."
      puts "    -h   Display this help screen."
      puts "    -u   Update gem-check."
      puts
    end

    def self.option?(argv, opts)
      argv.any? { |option| opts.include?(option) }
    end

    def self.update
      puts "\nThis will install the latest version of gem-check."
      print 'Continue? [Yn] '
      response = STDIN.gets.chomp
      puts "\n" + `gem install gem-check` if response.downcase.include?('y')
      puts
    end

    private

    def commafy(x)
      i,d = x.to_s.split('.')
      i.gsub(/(\d)(?=\d{3}+$)/,'\\1,') + (d ? ('.'+d) : '')
    end

    def decommafy(x)
      return x unless x.class.eql?(String)
      x.delete(',')
    end

    def update_status_string
      update_available? ? "\n [ Update available: v#{@update_version} ]" : nil
    end

    def header_string
      "GemCheck v#{GemCheck::VERSION}#{update_status_string}\n"+
      "#{current_date_string}\n"+
      "#{last_run}"
    end

    # adapted from https://stackoverflow.com/a/195894
    def last_run
      time_diff = @previous_date ? (Time.now - @previous_date).to_i : nil
      time_words =
      case time_diff
      when nil then nil
      when 0 then 'just now'
      when 1 then 'a second ago'
      when 2..59 then time_diff.to_s+' seconds ago'
      when 60..119 then 'a minute ago' #120 = 2 minutes
      when 120..3540 then (time_diff/60).to_i.to_s+' minutes ago'
      when 3541..7100 then 'an hour ago' # 3600 = 1 hour
      when 7101..82800 then ((time_diff+99)/3600).to_i.to_s+' hours ago'
      when 82801..172000 then 'a day ago' # 86400 = 1 day
      when 172001..518400 then ((time_diff+800)/(60*60*24)).to_i.to_s+' days ago'
      when 518400..1036800 then 'a week ago'
      else ((time_diff+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
      end

      time_words ? "#{commafy(@new_downloads)} downloads since #{time_words}" : ''
    end
  end
end
