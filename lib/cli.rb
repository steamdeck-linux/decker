require 'bundler/setup'
require "thor"

class DeckerCLI < Thor
  desc "install [PACKAGE]", "installs PACKAGE and registers it to Decker"
  def install(package)
    system("babushka.rb 'current dir:install' package_name=#{package}")
  end

  desc "remove [PACKAGE]", "removes PACKAGE and it's unique dependencies, from the system and from Decker"
  def remove(package)
    system("babushka.rb 'current dir:remove' package_name=#{package}")
  end

  desc "update", "updates packages registered to Decker"
  def update
    system("babushka.rb 'current dir:update'")
  end

  desc "patch [FILEPATH]", "registers file at FILEPATH to Decker, so it can be restored"
  def patch(filepath)
    system("babushka.rb 'current dir:patch' filepath=#{filepath}")
  end

  desc "restore", "restores all packages and patches to the system"
  def restore
    system("babushka.rb 'current dir:restore'")
  end
end
