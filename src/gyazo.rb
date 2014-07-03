#!/usr/bin/env ruby

# setting
browser_cmd = 'xdg-open'
clipboard_cmd = 'xclip'

require 'net/http'
require 'json'

# get id
idfile = ENV['HOME'] + "/.gyazo.id"

id = ''
if File.exist?(idfile) then
  id = File.read(idfile).chomp
end

# capture png file
tmpfile = "/tmp/image_upload#{$$}.png"
imagefile = ARGV[0]

auth_file = Dir.home + "/.iquestria/5LyCQXSW0c42P8N6.token"

body = ""

File.open(auth_file, "r") do |f|
  f.each_line do |line|
    body += line
  end
end

jsonbody = JSON.parse(body)
AUTH_TOKEN = jsonbody["token"]

if imagefile && File.exist?(imagefile) then
  system "convert '#{imagefile}' '#{tmpfile}'"
else
  system "import '#{tmpfile}'"
end

if !File.exist?(tmpfile) then
  exit
end

imagedata = File.read(tmpfile)
File.delete(tmpfile)

# upload
boundary = '----BOUNDARYBOUNDARY----'

HOST = 'iquestria.net'
CGI = '/gyazo.php'
UA   = 'iQuestria-Gyazo/1.0'

data = <<EOF
--#{boundary}\r
content-disposition: form-data; name="id"\r
\r
#{id}\r
--#{boundary}\r
content-disposition: form-data; name="imagedata"; filename="image.png"\r
\r
#{imagedata}\r
--#{boundary}--\r
EOF

header ={
  'Content-Length' => data.length.to_s,
  'Content-type' => "multipart/form-data; boundary=#{boundary}",
  'User-Agent' => UA,
  'Gyazo-Auth-Token' => AUTH_TOKEN
}

env = ENV['http_proxy']
if env then
  uri = URI(env)
  proxy_host, proxy_port = uri.host, uri.port
else
  proxy_host, proxy_port = nil, nil
end
Net::HTTP::Proxy(proxy_host, proxy_port).start(HOST,80) {|http|
  res = http.post(CGI,data,header)
  url = res.response.body
  puts url
  if system "which #{clipboard_cmd} >/dev/null 2>&1" then
    system "echo -n '#{url}' | #{clipboard_cmd}"
  end
  system "#{browser_cmd} '#{url}'"

  # save id
  newid = res.response['X-Gyazo-Id']
  if newid and newid != "" then
    if !File.exist?(File.dirname(idfile)) then
      Dir.mkdir(File.dirname(idfile))
    end
    if File.exist?(idfile) then
      File.rename(idfile, idfile+Time.new.strftime("_%Y%m%d%H%M%S.bak"))
    end
    File.open(idfile,"w").print(newid)
  end
}
