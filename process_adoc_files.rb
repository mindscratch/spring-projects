require 'fileutils'

def go
  files = Dir.glob('**/*.adoc')
  puts "found #{files.size} adoc files"

  files.each { |file| process_file file }
end

def process_file(file)
  # create a directory to store the adoc files that will be downloaded
  dir_name = 'remote_adoc'
  FileUtils.mkdir dir_name

  lines = File.readlines file
  File.open(file, 'w') do |fh|
    lines.each do |line|
      new_line = line
      if include_http_line?(line)
        # get the file
        m = line.match /include::(http[^\[]+)/
        if m
          url = m.captures.first
          x = `wget #{url}`
          if $?.success?
            file_name = File.basename url
            FileUtils.mv file_name, dir_name
            new_line = line.sub /http[^\[]+/, "#{dir_name}/#{file_name}"
          else
            puts "err: failed to download file, url=#{url}"
          end
        else
          puts "err: couldn't find URL, file=#{file}, line=#{line}"
        end
      end
      fh.puts new_line
    end
  end
  include_http_lines = lines.keep_if { |line| line =~ /include::http/ }
end

def include_http_line?(line)
  !!(line =~ /include::http/)
end

go
