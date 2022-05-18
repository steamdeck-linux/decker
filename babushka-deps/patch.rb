require_relative "../lib/patch"

dep 'patch', :filepath do
  requires [
    'initialise',
    'file patched'.with(filepath)
  ]
end

dep 'file patched', :filepath do
  patch = Decker::Patch.new(filepath.to_s)
  log("Saving patch #{filepath}")
  patch.save
end