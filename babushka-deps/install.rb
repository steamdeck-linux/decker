require_relative "../lib/package"

dep 'install', :package_name do
  requires [
    'initialise',
    'package installed'.with(package_name),
    'package registered'.with(package_name)
  ]
end

dep 'install dependency', :package_name do
  package = Decker::Package.new(package_name.to_s)
  met? {
    package.registered?
  }
  meet {
    shell("babushka.rb 'current dir:install' package_name='#{package_name}'")
  }
end

dep 'package installed', :package_name do
  package = Decker::Package.new(package_name.to_s)
  requires [
    "package check".with(package_name),
    "package dependencies listed".with(package_name)
    ]
  met? {
    package.installed?
  }
  meet {
    log("Installing package: #{package_name}")
    package.install
  }
end

dep 'package check', :package_name do
  met? {
    shell?("paru --getpkgbuild --print #{package_name}")
    }
  meet {
    unmeetable! "Invalid or group package specified. Group and virtual packages are not supported by Decker!"
    }
end

dep "package dependencies listed", :package_name do
  package = Decker::Package.new(package_name.to_s)
  met? {
    package.info.has_key?("dependencies")
  }
  meet {
    package.cached
  }
end

dep 'package registered', :package_name do
  log("Caching #{package_name}")
  package = Decker::Package.new(package_name.to_s)
  package_version = package.version
  requires [
    'package in db'.with(package_name, package_version),
    'package cached'.with(package_name, package_version),
    'children registered'.with(package_name)
  ]
end

dep 'package in db', :package_name, :package_version do
  met? {
    shell?("ls ~/.local/share/decker/db | grep #{package_name}-#{package_version}")
  }
  meet {
    shell("cp -r #{PACDBPATH}/#{package_name}-#{package_version}/ #{DBPATH}")
  }
end

dep 'package cached', :package_name, :package_version do
  package = Decker::Package.new(package_name.to_s)
  met? {
    shell?("ls #{PKGPATH} | grep #{package_name}-#{package_version}")
  }
  meet {
    package_file = package.package_file
    if !package_file
      package.install
      shell("sleep 1")
      package_file = package.package_file
    end
    sudo("cp -r #{package_file} #{PKGPATH}")
  }
end

dep 'children registered', :package_name do
  package = Decker::Package.new(package_name.to_s)
  required_deps = []
  package.cached.each do |dependency|
    return required_deps = ['package has no children'] if package.cached.empty?
    required_deps.append('install dependency'.with(dependency))
  end
  requires required_deps
end

dep 'package has no children' do
  met? { true }
end