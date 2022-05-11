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

class Decker

  def self.package_list
    JSON.parse(File.read(PKGLIST))
  end

  def self.register_package(package_name, package_version)
    return false if package_version.blank?
    packages = self.package_list
    data = {
      package_name.to_s => {
        version: package_version,
        updated_at: Time.now,
      }
    }
    if updated_packages = packages.merge(data)
      packages_json = JSON.pretty_generate(updated_packages)
      File.write(PKGLIST, packages_json)
      return true
    end
    false
  end

  def self.package_registered?(package_name)
    self.package_list.has_key?(package_name)
  end

  def self.registered_package(package_name)
    return false unless self.package_registered?(package_name)
    packages = self.package_list
    packages[package_name]
  end

  def self.has_dependencies?(package_name, dependencies)
    return false unless self.package_registered?(package_name)
    package["dependencies"].sort == dependencies.sort
  end

  def self.set_dependencies(package_name, dependencies)
    return false unless self.package_registered?(package_name)
    packages = self.package_list
    package = self.registered_package(package_name)
    package_dependencies = {"dependencies": dependencies}
    package.merge!(package_dependencies)
    if updated_packages = packages.merge(package_dependencies)
      packages_json = JSON.pretty_generate(updated_packages)
      File.write(PKGLIST, packages_json)
      return true
    end
    false
  end

  def self.registered_package_version(package_name)
    return false unless self.package_registered?(package_name)
    self.package_list[package_name.to_s]["version"]
  end

  def self.package_version(package_name)
    %x(pacman -Q #{package_name}).split(" ").last
  end

  def self.is_installed_package?(package_name)
    %x(pacman -Qk #{package_name})
    $?.success?
  end

  def self.find_package_in_path(path, package_name)
    package_version = package_version(package_name)
    return false unless Dir.exist?(fullpath)
    return false unless file = Dir.entries(fullpath).grep(/#{package_name}-#{package_version}.*pkg/).grep_v(/sig/).first
    "#{path}/#{file}"
  end

  def self.get_package_file(package_name)
    pacman = self.find_package_in_path(PACCACHEPATH, package_name)
    aur = self.find_package_in_path("#{PARUCACHEPATH}/#{package_name}", package_name)
    local = self.find_package_in_path(".", package_name)

    return pacman if pacman
    return aur if aur
    return local if local
    false
  end

  def self.package_registered_command_listing child_packages
    return false unless child_packages.class == Array
    child_packages.map { |package_name| self.package_registered_command package_name }
  end
  
  def self.package_registered_command package_name
    'package registered'.with(package_name)
  end
end