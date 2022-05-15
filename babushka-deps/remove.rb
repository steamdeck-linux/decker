require_relative "../lib/package"

dep 'remove', :package_name do
  requires [
    'deregister dependencies'.with(package_name),
    'remove package'.with(package_name)
  ]
end

dep 'deregister dependencies', :package_name do
  package = Decker::Package.new(package_name.to_s)
  required_deps = []
  package.unique_dependencies.each do |dependency|
    required_deps.append('deregister dependency'.with(dependency))
  end
  requires required_deps
end

dep 'deregister dependency', :package_name do
  package = Decker::Package.new(package_name.to_s)
  log("Removing #{package_name} from package list")
  met? {
    !package.registered_package?(package_name.to_s)
  }
  meet {
    package.deregister
  }
end

dep 'remove package', :package_name do
  package = Decker::Package.new(package_name.to_s)
  log("Uninstalling #{package_name}")
  met? {
    !package.registered_package?(package_name.to_s)
  }
  meet {
    package.uninstall
  }
end