require 'bundler/setup'
require "thor"

class DeckerCLI < Thor
  desc "install [PACKAGE]", "installs PACKAGE and registers it to Decker"
  def install(package)
    exec("babushka.rb 'current dir:install' package_name=#{package}")
  end

  desc "remove [PACKAGE]", "removes PACKAGE and it's unique dependencies, from the system and from Decker"
  def remove(package)
    exec("babushka.rb 'current dir:remove' package_name=#{package}")
  end

  desc "update", "updates packages registered to Decker"
  def update
    exec("babushka.rb 'current dir:update'")
  end

  desc "patch [FILEPATH]", "registers file at FILEPATH to Decker, so it can be restored"
  def patch(filepath)
    exec("babushka.rb 'current dir:patch' filepath=#{filepath}")
  end

  desc "restore", "restores all packages and patches to the system"
  def restore
    exec("babushka.rb 'current dir:restore'")
  end
end
