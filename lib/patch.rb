require_relative "decker"
require 'fileutils'
require 'date'
include Decker

module Decker
  class Patch < Main

    def initialize(filepath)
      @filepath = File.expand_path(filepath)
      raise "Invalid file" unless File.file?(@filepath) || Main.patch_list.has_key?(@filepath)
      @id = Time.now.strftime("%Y%M%d%H%M%S")
      @time = Time.now.round.to_s
    end

    def self.all
      Main.patch_list.keys
    end

    def patch_list
      Main.patch_list
    end

    def info
      return patch_list[@filepath] if patch_list.has_key?(@filepath)
      if write_to_patchlist(@filepath, {})
        return {}
      end
      raise "Patch info could not be written"
    end

    def all
      info.keys
    end

    def latest
      newest_time = Time.new(0)
      id = ""
      all.each do |patch|
        patch_info = info[patch]
        time = DateTime.parse(patch_info["time"]).to_time
        if time > newest_time
          newest_time = time
          id = patch
        end
      end
      id
    end

    def patch_file(id = latest)
      return false unless id
      info[id]["patch"]
    end

    def mode(id = latest)
      return false unless id
      info[id]["mode"]
    end

    def uid(id = latest)
      return false unless id
      info[id]["uid"]
    end

    def gid(id = latest)
      return false unless id
      info[id]["gid"]
    end

    def patchfile(id = @id)
      "#{PATCHPATH}/#{id}.patch"
    end

    def create_patch
      system("sudo cp #{@filepath} #{patchfile}")
    end

    def save
      raise "Invalid file" unless File.file?(@filepath)
      stat = File.stat(@filepath)
      uid = stat.uid
      gid = stat.gid
      mode = stat.mode.to_s(8).slice!(2..)
      create_patch
      data = {
        patch: patchfile,
        uid: uid,
        gid: gid,
        mode: mode,
        time: @time
      }
      write_patch_info(@id, data)
    end

    def restore(id = latest)
      file = patch_file(id)
      uid = uid(id)
      gid = gid(id)
      mode = mode(id)
      system("sudo cp #{file} #{@filepath}")
      system("sudo chown #{uid} #{@filepath}")
      system("sudo chgrp #{gid} #{@filepath}")
      system("sudo chmod #{mode} #{@filepath}")
    end

    private

    def write_patch_info(key, value)
      data = {key => value}
      patch_info = info
      patch_info.merge!(data)
      write_to_patchlist(@filepath, patch_info)
    end
  end
end