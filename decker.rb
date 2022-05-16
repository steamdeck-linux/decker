#!/usr/bin/env ruby

appdir = ENV["APPDIR"]
Dir.chdir("#{appdir}/usr/local/decker") if appdir

require_relative "lib/cli"

DeckerCLI.start(ARGV)
