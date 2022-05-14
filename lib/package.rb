require_relative "decker"
include Decker

module Decker
  class Package < Main

    def initialize(package_name)
      raise "Invalid Package" unless valid_package?(package_name)
      @name = package_name
    end

    def installed?(package = @name)
      system("paru -Qk #{package} &> /dev/null")
    end

    def registered?
      package_list.has_key?(@name)
    end

    def info
      return package_list[@name] if package_list.has_key?(@name)
      if write_to_pkglist(@name, {})
        return {}
      end
      raise "Package info could not be written"
    end

    def version
      raise "Package not installed" unless installed?
      return info["version"] if info.has_key?("version")
      version = %x(paru -Q #{@name}).split(" ").last
      if write_package_info("version", version)
        return version
      end
      raise "Version could not be written"
    end

    def dependencies
      return info["dependencies"] if info.has_key?("dependencies")
      if write_package_info("dependencies", get_dependencies)
        return dependencies
      end
      raise "Dependencies could not be written"
    end

    def cached
      return info["cached"] if info.has_key?("cached")
      cached = dependencies.select {|dependency| !installed?(dependency)}
      return cached if cached.empty?
      if write_package_info("cached", cached)
        return cached
      end
      raise "Cached dependencies could not be written"
    end

    def install
      system("paru -S #{@name} --skipreview --norebuild --removemake")
    end

    def package_file
      raise "Package not installed" unless version
      pacman = find_package_in_path(PACCACHEPATH)
      aur = find_package_in_path("#{PARUCACHEPATH}/#{@name}")
      local = find_package_in_path(".")

      return pacman if pacman
      return aur if aur
      return local if local
      false
    end

    private

    def get_dependencies
      pkgbuild = get_pkgbuild(@name)
      dependencies = pkgbuild.match(/^(depends=)\([\s\S][^\)]*\)/).to_s
      cleanup_dependencies(dependencies)
    end

    def cleanup_dependencies(dependencies)
      dependencies.gsub!(/[\(\)'"]/, "")
      dependencies.gsub!("depends=", "")
      dependencies.gsub!(/((>=)|(<=)|(>)|(<)|(=))\S*/, "")
      dependency_array = dependencies.split(" ")
      dependency_array.select {|dependency| !dependency.end_with?(".so") }
    end

    def write_package_info(key, value)
      data = {key => value}
      package_info = info
      package_info.merge!(data)
      write_to_pkglist(@name, package_info)
    end

    def find_package_in_path(path)
      return false unless Dir.exist?(path)
      return false unless file = Dir.entries(path).grep(/#{@name}-#{version}.*pkg/).grep_v(/sig/).first
      "#{path}/#{file}"
    end
  end
end