require_relative "../lib/decker"

dep 'initial setup' do
  required_deps = ['setup complete']
  required_deps = ['setup', 'mark setup complete'] unless File.file?(SETUPCHECK)
  requires required_deps
end

dep 'setup' do
  requires [
    'setup device',
    'base devel'
  ]
end

dep 'setup device' do
  requires [
    'password set',
    'read only disabled',
    'pacman keys'
  ]
end

dep 'password set' do
  met? {
    shell("sudo touch /dev/null")
  }
  meet {
    shell("passwd")
  }
end

dep 'read only disabled' do
  sudo("steamos-readonly disable")
end

dep 'pacman keys' do
  sudo("pacman-key --init")
  sudo("pacman-key --populate archlinux")
end

dep 'base devel' do
  base_devel = %w[grep findutils git gawk m4 autoconf automake binutils gettext bison sed file fakeroot flex gcc groff gzip libtool texinfo make patch pkgconf which]
  required_deps = []
  base_devel.each do |package|
    required_deps.push('install package'.with(package))
  end
  requires required_deps
end

dep 'mark setup complete' do
  met? {
    File.file?(SETUPCHECK)
  }
  meet {
    shell("touch #{SETUPCHECK}")
  }
end

dep 'setup complete' do
  met? { true }
end