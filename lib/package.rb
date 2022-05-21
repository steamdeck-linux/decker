require_relative "decker"
include Decker

module Decker
  class Package < Main

    def self.all
      Main.package_list.keys
    end

    def package_list
      Main.package_list
    end

    def initialize(package_name)
      raise "Package '#{package_name}' is invalid!" unless valid_package?(package_name)
      @name = package_name
    end

    def installed?(package = @name)
      system("paru -Qk #{package} &> /dev/null")
    end

    def in_pacman_db?
      File.exist?("#{PACDBPATH}/#{@name}-#{version}")
    end

    def registered?
      package_list.has_key?(@name)
    end

    def info
      return package_list[@name] if package_list.has_key?(@name)
      if write_to_pkglist(@name, {})
        return {}
      end
      raise "Package info could not be written to file."
    end

    def version
      return info["version"] if info.has_key?("version")
      false
    end

    def get_version
      return info["version"] if info.has_key?("version")
      update_version
    end

    def update_version
      raise "Package '#{@name}' not installed" unless installed?
      version = %x(paru -Q #{@name}).split(" ").last
      if write_package_info("version", version)
        return version
      end
      raise "Version '#{version}' for package '#{@name}' could not be written to file."
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
      raise "Cached dependencies '#{cached}' could not be written to file."
    end

    def required_by
      package_list = Package.all
      packages = package_list.reject { |package| package == @name }
      package_required_by = []
      packages.each do |package_name|
        package = Package.new(package_name)
        package_required_by.push(package_name) if package.dependencies.include?(@name)
      end
      package_required_by
    end

    def unique_dependencies
      unique = []
      check_dependencies = cached.push(@name)
      cached.each do |cached_dependency|
        package = Package.new(cached_dependency)
        packages_require = package.required_by - check_dependencies
        unique.push(cached_dependency) if packages_require.empty?
      end
      unique
    end

    def install
      system("paru -S #{@name} --skipreview --norebuild --removemake")
    end

    def install_from_cache
      system("paru -U #{package_file}")
    end

    def uninstall
      deregister
      system("paru -Rs #{@name}")
    end

    def deregister
      remove_from_pkglist(@name)
    end

    def package_file
      cache = find_package_in_path(PKGPATH)
      pacman = find_package_in_path(PACCACHEPATH)
      aur = find_package_in_path("#{PARUCACHEPATH}/#{@name}")
      local = find_package_in_path(".")

      return cache if cache
      return pacman if pacman
      return aur if aur
      return local if local
      raise "Package file for package '#{@name}' is missing!"
    end

    def db_file
      db_path = "#{DBPATH}/#{@name}-#{version}"
      raise "DB File missing!" unless File.exist?("#{DBPATH}/#{@name}-#{version}")
      db_path
    end

    private

    def get_dependencies
      pkgbuild = get_pkgbuild(@name)
      dependencies = pkgbuild.match(/^(depends=)\([\s\S][^\)]*\)/).to_s
      cleanup_dependencies(dependencies).uniq
    end

    def cleanup_dependencies(dependencies)
      dependencies.gsub!(/[\(\)'"]/, "")
      dependencies.gsub!("depends=", "")
      dependencies.gsub!(/((>=)|(<=)|(>)|(<)|(=))\S*/, "")
      dependency_array = dependencies.split(" ")
      special = "?<>',?[]}{=)(*&^%$#`~{}"
      regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
      dependency_array.delete_if {|dependency| dependency =~ regex}
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