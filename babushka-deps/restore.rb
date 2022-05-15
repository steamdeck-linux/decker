require_relative "../lib/package"

dep 'restore' do
  requires [
    'initialise',
    'package db restored',
    'packages installed from cache'
  ]
end

dep 'package db restored' do
  packages = Decker::Package.all
  depends_array = []
  packages.each do |package|
    depends_array.append('package restore db'.with(package))
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
    depends_array.append('package install from cache'.with(package))
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