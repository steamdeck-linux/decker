#!/usr/bin/env ruby

appdir = ENV["APPDIR"]
Dir.chdir("#{appdir}/usr/local/decker") if appdir

require_relative "lib/cli"

trap "SIGINT" do
  puts "Decker Exited"
  exit 130
end

DeckerCLI.start(ARGV)
