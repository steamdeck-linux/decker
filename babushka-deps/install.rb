require_relative "../lib/package"

dep 'install', :package_name do
  requires [
    'initialise',
    'install package'.with(package_name)
  ]
end

dep 'install package', :package_name do
  requires [
    'package installed'.with(package_name),
    'package registered'.with(package_name)
  ]
end

dep 'install dependency', :package_name do
  package = Decker::Package.new(package_name.to_s)
  met? {
    package.registered?
    package.get_version
  }
  meet {
    log("Installing dependency #{package_name}")
    system("babushka.rb 'current dir:install' package_name='#{package_name.to_s}'")
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
    package.get_version
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
    package.info.has_key?("dependencies") || package.dependencies == :blank
  }
  meet {
    package.cached
  }
end

dep 'package registered', :package_name do
  log("Caching #{package_name}")
  package = Decker::Package.new(package_name.to_s)
  package_version = package.get_version
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
  if package.dependencies == :blank
    met? { true }
  else
    required_deps = []
    package.cached.each do |dependency|
      return required_deps = ['package has no children'] if package.cached.empty?
      required_deps.push('install dependency'.with(dependency))
    end
    requires required_deps
  end
end

dep 'package has no children' do
  met? { true }
end
