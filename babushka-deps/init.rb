require_relative "../lib/decker"

dep "initialise" do
  requires [
    "package list",
    "patch list",
    "package db",
    "patch db",
    "git cache",
    "package cache"
  ]
end

dep "package list" do
  met? {
    shell?("cat #{PKGLIST}")
  }
  meet {
    shell("mkdir -p #{LOCALPATH}")
    shell("echo {} > #{PKGLIST}")
  }
end

dep "patch list" do
  met? {
    shell?("cat #{PATCHLIST}")
  }
  meet {
    shell("mkdir -p #{LOCALPATH}")
    shell("echo {} > #{PATCHLIST}")
  }
end

dep "package db" do
  met? {
    Dir.exist?(File.expand_path(DBPATH))
  }
  meet {
    shell("mkdir -p #{DBPATH}")
  }
end

dep "patch db" do
  met? {
    Dir.exist?(File.expand_path(PATCHPATH))
  }
  meet {
    shell("mkdir -p #{PATCHPATH}")
  }
end

dep "git cache" do
  met? {
    Dir.exist?(File.expand_path(GITPATH))
  }
  meet {
    shell("mkdir -p #{GITPATH}")
  }
end

dep "package cache" do
  met? {
    Dir.exist?(File.expand_path(PKGPATH))
  }
  meet {
    shell("mkdir -p #{PKGPATH}")
  }
end
