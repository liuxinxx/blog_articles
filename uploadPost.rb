require "pp"
require "json"
require 'httparty'
require 'open-uri'
require 'net/http'
include HTTParty
puts "#{ARGV[0]}"
temp_data = {}
content = ''
flag = false
i = 0
key = ''
lines = File.open("./key.config").readlines
lines.each do |line|
  key = line.gsub(/\n/,"")
end

lines = File.open("./#{ARGV[0]}").readlines
lines.each do |line|

  if line === "```\n"
    i+=1
  end

  if i == 1
    unless line =~ /```\n/
      temp = line.gsub(/\n/,"").split(":")
      if temp[0] == 'tags'
        temp_data[temp[0].to_s] = temp[1]
      else
        temp_data[temp[0].to_s] = line.gsub(temp[0],"").gsub(/\n/,"")
      end
    end
  end
  if i == 2
    i+=1
    line = ""
  end
  if i > 2
    content << line
  end
end
puts '================'
p temp_data
puts '================'
url =URI.parse "http://liuxin.im"
data = {
  'tags' =>  temp_data["tags"],
  'title' =>  ARGV[0].gsub("\"","").gsub(".md",""),
  'content' =>  content,
  'source_title' =>  temp_data.key?("source_title") ? temp_data["source_title"].sub(":","") : "liuxin's blog",
  'source_url' =>  temp_data.key?("source_url") ? temp_data["source_url"].sub(":","") : "",
  'api_key' =>  key,
}
header = {
  "Content-Type": "application/json;charset=UTF-8",
  # "Content-Type": "application/x-www-form-urlencoded"
}

http = Net::HTTP.new(url.host, url.port)
request_method = 'POST'
p JSON.parse http.send_request(request_method,"/api/v1/articles",JSON.dump(data),header).body

puts `git status`

puts `git add "#{ARGV[0]}"`

puts `git commit -m "#{ARGV[0]}"`

puts `git push origin master`

puts 'success!'
