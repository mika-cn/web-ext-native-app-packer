
Gem::Specification.new do |s|
  s.name        = 'web-ext-native-app-packer'
  s.version     = '1.0.2'
  s.summary     = 'web extension native application packer!'
  s.description = <<-EOF
    web extension native application packer!
  EOF
  s.date        = '2018-07-17'
  s.author      = 'Mika'
  s.email       = 'Mika@nothing.org'
  s.homepage    = 'https://github.com/mika-cn/web-ext-native-app-packer'
  s.license     = 'MIT'
  s.executables << 'web-ext-native-app-packer'
  s.files = [
    "README.md",
    "bin/web-ext-native-app-packer",
    "lib/web-ext-native-app-packer.rb",
    "lib/pack.sh",
    "lib/template/manifest.json.erb",
    "lib/template/app-loader.bat.erb",
    "lib/template/install-unix-like.sh.erb",
    "lib/template/install-windows.bat.erb",
    "lib/template/uninstall-unix-like.sh.erb",
    "lib/template/uninstall-windows.bat.erb"
  ]
  s.test_files = []
end
