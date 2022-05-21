require_relative "../lib/package"
require_relative "../lib/patch"

dep 'restore' do
  requires [
    'initialise',
    'setup',
    'restore all packages',
    'restore all patches'
  ]
end

dep 'restore all packages' do
  packages = Decker::Package.all
  depends_array = []
  packages.each do |package|
    depends_array.push('restore package'.with(package))
  end
  requires depends_array
end

dep 'restore package', :package_name do
  requires [
    'package has version'.with(package_name),
    'package restore db'.with(package_name),
    'package install from cache'.with(package_name)
  ]
end

dep 'package has version', :package_name do
  package = Decker::Package.new(package_name.to_s)
  met? {
    package.version if package
  }
  meet {
    confirm_text = "Package does not have a version listed. Delete #{package_name} from Decker?"
    otherwise_text = "Please edit '#{PKGLIST}', and add a version key to #{package_name}, with the correct version string."
    confirm confirm_text, otherwise: otherwise_text do
      package.deregister
      package = false
      log "Package '#{package_name}' removed from Decker. Please re-run restore to continue."
      log "If '#{package_name}' was needed, please run 'sudo pacman -Rs #{package_name}', then re-install it in Decker."
    end
  }
end

dep 'package restore db', :package_name do
  package = Decker::Package.new(package_name.to_s)
  met? {
    package.in_pacman_db?
  }
  meet {
    log("Restoring #{package_name} to db")
    sudo("cp -r #{package.db_file} #{PACDBPATH}/")
  }
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

dep 'restore all patches' do
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
