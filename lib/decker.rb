require 'json'
require "#{ENV["BABUSHKA_PATH"]}/lib/babushka"
include Babushka::DSL

LOCALPATH = File.expand_path("~/.local/share/decker")
CACHEPATH = File.expand_path("~/.cache/decker")
PKGLIST = File.expand_path("~/.local/share/decker/packagelist.json")
GITPATH = File.expand_path("~/.cache/decker/git")
PKGPATH = File.expand_path("~/.cache/decker/pkg")
DBPATH = File.expand_path("~/.local/share/decker/db")
PATCHPATH = File.expand_path("~/.local/share/decker/patch")
PATCHLIST = File.expand_path("~/.local/share/decker/patchlist.json")
PACDBPATH = File.expand_path("/var/lib/pacman/local")
PACCACHEPATH = File.expand_path("/var/cache/pacman/pkg")
PARUCACHEPATH = File.expand_path("~/.cache/paru/clone")
SETUPCHECK = File.expand_path("~/.cache/decker/setup")

module Decker
  class Main

    def self.package_list
      JSON.parse(File.read(PKGLIST))
    end

    def self.patch_list
      JSON.parse(File.read(PATCHLIST))
    end

    def valid_package?(package_name)
      return true if registered_package?(package_name)
      system("paru --getpkgbuild --print #{package_name} > /dev/null")
    end

    def registered_package?(package_name)
      package_list.has_key?(package_name)
    end

    def get_pkgbuild(package_name)
      %x(paru --getpkgbuild --print #{package_name})
    end

    def remove_from_pkglist(package_name)
      packages = Main.package_list
      packages.delete(package_name)
      packages_json = JSON.pretty_generate(packages)
      File.write(PKGLIST, packages_json)
    end

    def write_to_pkglist(package_name, package_info)
      write_to_file(PKGLIST, Main.package_list, package_name, package_info)
    end

    def write_to_patchlist(patch_name, patch_info)
      write_to_file(PATCHLIST, Main.patch_list, patch_name, patch_info)
    end

    def write_to_file(file, list, key, info)
      data = { key => info }
      list.merge!(data)
      json = JSON.pretty_generate(list)
      File.write(file, json)
    end

  end
end