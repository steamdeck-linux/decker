require_relative "../lib/package"
require_relative "../lib/patch"

dep 'restore' do
  requires [
    'initialise',
    'package db restored',
    'packages installed from cache',
    'patches restored'
  ]
end

dep 'package db restored' do
  packages = Decker::Package.all
  depends_array = []
  packages.each do |package|
    depends_array.push('package restore db'.with(package))
  end
  requires depends_array
end

dep 'package restore db', :package_name do
  package = Decker::Package.new(package_name.to_s)
  log("Restoring #{package_name} to db")
  met? {
    package.in_pacman_db?
  }
  meet {
    sudo("cp -r #{package.db_file} #{PACDBPATH}/")
  }
end

dep 'packages installed from cache' do
  packages = Decker::Package.all
  depends_array = []
  packages.each do |package|
    depends_array.push('package install from cache'.with(package))
  end
  requires depends_array
end

dep 'package install from cache', :package_name do
  package = Decker::Package.new(package_name.to_s)
  log("Installing #{package_name}")
  met? {
    package.installed?
  }
  meet {
    package.install_from_cache
  }
end

dep 'patches restored' do
  patches = Decker::Patch.all
  required_deps = []
  patches.each do |patch|
    required_deps.push('restore patch'.with(patch))
  end
  requires required_deps
end

dep 'restore patch', :filepath do
  patch = Decker::Patch.new(filepath.to_s)
  log("Restoring patch #{filepath}")
  patch.restore
end