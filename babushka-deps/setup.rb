require_relative "../lib/decker"

dep 'initial setup' do
  required_deps = ['setup complete']
  required_deps = ['setup', 'mark setup complete'] unless File.file?(SETUPCHECK)
  requires required_deps
end

dep 'setup' do
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