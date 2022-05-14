require 'json'

LOCALPATH = File.expand_path("~/.local/share/decker")
CACHEPATH = File.expand_path("~/.cache/decker")
PKGLIST = File.expand_path("~/.local/share/decker/packagelist.json")
GITPATH = File.expand_path("~/.cache/decker/git")
PKGPATH = File.expand_path("~/.cache/decker/pkg")
DBPATH = File.expand_path("~/.local/share/decker/db")
PATCHPATH = File.expand_path("~/.local/share/decker/patch")
PACDBPATH = File.expand_path("/var/lib/pacman/local")
PACCACHEPATH = File.expand_path("/var/cache/pacman/pkg")
PARUCACHEPATH = File.expand_path("~/.cache/paru/clone")

module Decker
  class Main

    def package_list
      JSON.parse(File.read(PKGLIST))
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

    def write_to_pkglist(package_name, package_info)
      data = { package_name => package_info }
      packages = package_list
      packages.merge!(data)
      packages_json = JSON.pretty_generate(packages)
      File.write(PKGLIST, packages_json)
    end

  end
end