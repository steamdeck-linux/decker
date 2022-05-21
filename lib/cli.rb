require "bundler/setup"
require "thor"
require_relative "decker"

class DeckerCLI < Thor
  desc "install [PACKAGE]", "installs PACKAGE and registers it to Decker"
  def install(package)
    Dep('current dir:install').meet(package)
  end

  desc "remove [PACKAGE]", "removes PACKAGE and it's unique dependencies, from the system and from Decker"
  def remove(package)
    Dep('current dir:remove').meet(package)
  end

  desc "update", "updates packages registered to Decker"
  def update
    Dep('current dir:update').meet
  end

  desc "search [PACKAGE]", "searches for packages matching PACKAGE"
  def search(package)
    system("paru -Ss #{package}")
  end

  desc "patch [FILEPATH]", "registers file at FILEPATH to Decker, so it can be restored"
  def patch(filepath)
    Dep('current dir:patch').meet(filepath)
  end

  desc "restore", "restores all packages and patches to the system"
  def restore
    Dep('current dir:restore').meet
  end
end
