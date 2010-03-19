#!/usr/bin/env ruby -w

# Original version found on http://blog.bleything.net/pages/mateup

ENV['LC_ALL']   = nil
ENV['LC_CTYPE'] = 'en_US.UTF-8'

svn_root = 'http://svn.textmate.org/trunk/Bundles/'
bundles = [
  'Mediawiki', 'DokuWiki'
]

# escape spaces and ampersands
def cleanup(str)
  return str.gsub(/([ &])/, '\\\\\1')
end

dir = "#{ENV['HOME']}/Library/Application\ Support/TextMate/Bundles"
begin
  Dir.chdir dir
rescue Errno::ENOENT
  puts "Bundles directory doesn't exist... creating it!"
  puts
  
  `mkdir -p #{dir}`
  retry
end

Dir.entries('.').each do |e|
  next if e =~ /^\./
  next unless File.directory? e
  
  bundle_name = e.gsub(/.tmbundle$/, '')

  print "* #{bundle_name}: "

  if bundles.delete bundle_name
    puts "bundle exists, updating"
    `svn up #{cleanup e}`.match(/(revision \d+)/)
    puts "  * updated to #{$1}"
  else
    print "don't know about this bundle.  Delete it? [y/N] "

    while answer = gets
      if answer =~ /^y/
        `rm -rf #{cleanup e}`
        puts "  * deleted"
        break
      elsif answer =~ /^(n|$)/
        break
      else
        print "Please enter 'y' or 'n': "
      end
    end
  end
end

bundles.each do |bundle|
  puts "* #{bundle} doesn't exist; fetching..."
  cmd = "svn co #{svn_root}/#{cleanup bundle}.tmbundle"
  `#{cmd}`.match(/(revision \d+)/)
  puts "  * checked out #{$1}"
end