# Ruby 1.9.2+
puts RUBY_VERSION

require 'rubygems'
require 'parseconfig'
require 'rubyXL'
require 'find'

=begin
  How to use this utility:
  This utitlity can be used to create redirects whenever EADID's are changed,
  and therefore the URLs of published finding aids has changed.
  
  It takes as input an Excel worksheet with a column of Old EADIds and 
  a column of new EADIDs.
  
  For each row, it will:
  - Try to determine if there is a published finding aid matching the old ID
  - Determine if there is a published finding aid for the new EADID, and, if
    there is not, attempt to locate an EAD file matching the ID and publish it
  
  - If both conditions can be met, it will then:
    1) Add the obsolete URL to a list of URLs to be unpublished
    2) Add the Apache Redirection directive to a list of directives
    
  - When it is finished, it will output two reports:
    1) A list of URLs to unpublish
    2) A list of Redirects to be added to the Apache conf file

  Usage:
  ruby process-eadid-updates.rb PATH_TO_EXCEL_FILE

=end

conf_file = '../conf/eadpublisher.conf'
repos_code = 'tamwag'

#debug = true
debug = false

#Make sure configuration file exists
unless File.exist?(conf_file)
  puts "Could not find conf file at #{conf_file}"
  exit
end

#Get configurations
config = ParseConfig.new(conf_file)

CONTENT_PATH = config.get_value('CONTENT_PATH')
CONTENT_URI = config.get_value('CONTENT_URI')

unless ARGV.length == 1
  puts "This utility requires 1 argument, which is a path to an Excel spreadsheet file."
  puts "Usage: ruby process-eadid-updatdes.rb <PATH TO EXCEL FILE>"
  exit
end

input_file = ARGV[0]

unless File.exist?(input_file)
  puts "The file #{input_file} appears not to exist"
  exit
end

#x = ExcelSource.new(collid, ARGV[0])
book = RubyXL::Parser.parse(input_file)


faurlmap = Hash.new
error_types = Hash[
	"1" => "Can't find a Source EAD with this eadid", 
	"2" => "Attempted to transform the source EAD, but was not successful", 
    	"3" => "Found more than one source EAD with this eadid"
	]

puts "Iterate through rows" if debug
book[0].sheet_data.each do |row|
  if row[0] != nil
    
    oldid = row[0].value
    newid = row[1].value

#    next unless newid =~ /tam_50(.*)/
    puts "#{oldid} - #{newid}" if debug





    # Test if there is anything published under the old ID
    faurlmap[newid] = Hash["oldurl" => nil, "newurl" => nil, "error-type" => nil, "republished" => false]
    
    puts "Testing new, then old style file:" if debug
    #First, see if the ID was published using the newer stylesheet
    if File.exist?("#{CONTENT_PATH}/html/#{repos_code}/#{oldid}/index.html")
      faurlmap[newid]["oldurl"] = "#{CONTENT_URI}/html/#{repos_code}/#{oldid}"
      puts "new-style file found" if debug
    elsif File.exist?("#{CONTENT_PATH}/html/#{repos_code}/#{oldid}.html")
      puts "old-style file found" if debug
      #It's not guaranteed that this was created from an EAD with that eadid, so it's necessary to check.
      if File.exist?("#{CONTENT_PATH}/ead/#{repos_code}/#{oldid}.xml")
        puts "Found source EAD for the old pub" if debug
        unless open("#{CONTENT_PATH}/ead/#{repos_code}/#{oldid}.xml").grep(/<eadid(.*)>#{oldid}<\/eadid>/).empty?
          faurlmap[newid]["oldurl"] = "#{CONTENT_URI}/html/#{repos_code}/#{oldid}.html"
        end
      end
    end

    #Second, see if the new ID can be identified with a published FA, and,
    # if not, attempt to publish it
    puts "Check new ID" if debug
    if File.exist?("#{CONTENT_PATH}/html/#{repos_code}/#{newid}/index.html")
      puts "found a published match for new ID" if debug
      faurlmap[newid]["newurl"] = "#{CONTENT_URI}/html/#{repos_code}/#{newid}"
    else 
      matching_files = []
      Find.find("#{CONTENT_PATH}/ead/#{repos_code}") do |f|
        next unless f  =~ /(.*)\.xml$/
        next unless File.read("#{f}") =~ /<eadid(.*)>#{newid}<\/eadid>/
	puts "#{f}" if debug
	puts File.mtime("#{f}") if debug
        matching_files << [f, File.mtime("#{f}")]
      end
      if matching_files.length > 1 
        puts "Warning: thereare more than one EAD with ID #{newid}." if debug
	#Use the file with the more recent timestamp
	puts matching_files
	matching_files.sort {|m1,m2| m1[1] <=> m2[1]}
	matching_files.reverse
	puts matching_files if debug
	if matching_files[0][1] == matching_files[1][1]		
          faurlmap[newid]["error-type"] = "3"
	else
	  matching_files = matching_files.take(1)
	  puts "timestamp: #{matching_files[0][1]}" if debug
	end
      elsif matching_files.length == 0
	puts "Warning: there are no EADs with ID #{newid}." if debug
	faurlmap[newid]["error-type"] = "1"
      end
      if matching_files.length == 1
        puts "Going to publish #{newid} now." if debug
        file_id = File.basename(matching_files[0][0]).gsub(/\.xml/, "")
        pubout = `./redo-ead-transforms.bash #{repos_code}/#{file_id}` unless debug
        # Test again if the new ID can be identified with a published FA
        if File.exist?("#{CONTENT_PATH}/html/#{repos_code}/#{newid}/index.html")
          faurlmap[newid]["newurl"] = "#{CONTENT_URI}/html/#{repos_code}/#{newid}"
          faurlmap[newid]["republished"] = true
        else
          faurlmap[newid]["error-type"] = "2"
       end     
      end
    end
  end  
end

redirects = []
newlypubd = []
noactions = []
faurlmap.each do |key, urls|
  if urls["oldurl"] != nil and urls["newurl"] != nil
    oldpath = urls["oldurl"].gsub(/^(.*?)\.edu\//, "")
    redirects << "Redirect permanent #{oldpath} #{urls['newurl']}"
  elsif urls["newurl"] != nil and urls["republished"]
    newlypubd << urls["newurl"]     
  else
    noactions << Hash["newid" => key, "error-type" => urls["error-type"]]
  end
end

# Report Out

puts "====================="
puts "These rows generated no action:"
error_types.each do |key, mssg|
  puts mssg
  noactions.each do |h|
    next unless h["error-type"] == key
    puts h["newid"]
  end
end

puts "====================="
puts "The following new EADIDs were published but do not require redirects:"
newlypubd.each do |n|
  puts n
end

puts "====================="
puts "The following new EADIDs do require redirects:"
redirects.each do |r|
  puts r
end  
