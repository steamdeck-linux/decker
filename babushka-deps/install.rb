require_relative "decker.rb"

dep 'install', :package_name do
  requires [
    'package installed'.with(package_name),
    'package registered'.with(package_name)
  ]
end

dep 'package installed', :package_name do
  met? {
    shell?("pacman -Qk #{package_name}")
  }
  meet {
    log("Installing package: #{package_name}") 
    shell("echo '1\n' | yay -S #{package_name} --answerclean None --answerdiff None --answeredit None --removemake --norebuild", spinner: true)
  }
end

dep 'package registered', :package_name do
  package_version = Decker.package_version(package_name)
  requires [
    'package in list up to date'.with(package_name, package_version),
    'package in db'.with(package_name, package_version),
    'package cached'.with(package_name, package_version)
  ]
end

dep 'package in list up to date', :package_name, :package_version do
  requires [
    'package in packagelist'.with(package_name, package_version)
  ]
  met? {
    shell?("cat ~/.local/share/decker/packages.csv | grep #{package_name},#{package_version}")
  }
  meet {
    line = shell("cat #{PKGLIST} | grep -n #{package_name}, | cut -d : -f 1")
    shell("sed -i '#{line}s/.*/#{package_name},#{package_version}/' #{PKGLIST}")
  }
end

dep 'package in packagelist', :package_name, :package_version do
  met? {
    shell?("cat ~/.local/share/decker/packages.csv | grep #{package_name},")
  }
  meet {
    shell("echo '#{package_name},#{package_version}' >> #{PKGLIST}")
  }
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
  met? {
    shell?("ls #{PKGPATH} | grep #{package_name}-#{package_version}")
  }
  meet {
    package = Decker.get_package_file(package_name)
    sudo("cp -r #{package} #{PKGPATH}")
  }
end