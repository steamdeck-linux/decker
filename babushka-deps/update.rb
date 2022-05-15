require_relative "../lib/package"

dep 'update' do
  requires [
    'update system',
    'update packages in list'
  ]
end

dep 'update system' do
  system("paru -Syu")
end

dep 'update packages in list' do
  packages = Decker::Package.all
  depends_array = []
  packages.each do |package|
    depends_array.append('update package'.with(package))
  end
  requires depends_array
end

dep 'update package', :package_name do
  package = Decker::Package.new(package_name.to_s)
  version = package.update_version
  log("Updating #{package_name}")
  requires [
    'package in db'.with(package_name.to_s, version),
    'package cached'.with(package_name.to_s, version)
  ]
end