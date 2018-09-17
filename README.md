
# web ext native app packer

A tool to pack web extension native application.

# usage

1. install gem
```shell
gem install web-ext-native-app-packer
```

2. create pack.yaml in your native App directory
```yaml
app_name: 'awesome_app'
app_description: 'description of awesome_app'
app_path: 'main.rb'
execute_cmd: 'ruby'
# your web extension's firefox extension id
extension_id: 'awesome_app@example.org'
# your web extension's chrome extension origin (format => "chrome-extension://$id/")
extension_origin: 'chrome-extension://abtwertkbasdftllwerwh/'
```

3. run pack command
```shell
# web-ext-native-app-packer $native-app-directory $output-dir
web-ext-native-app-packer my-extension/native-app dist
```


# result
```shell
> tree ./dist
./dist/
├── awesome-app-linux-chrome.zip
├── awesome-app-linux-chromium.zip
├── awesome-app-linux-firefox.zip
├── awesome-app-osx-chrome.zip
├── awesome-app-osx-chromium.zip
├── awesome-app-osx-firefox.zip
├── awesome-app-windows-chrome.zip
├── awesome-app-windows-chromium.zip
└── awesome-app-windows-firefox.zip
```

It will generate some file to help extension user to Install(uninstall) native application

```
# Windows
app_loader.bat  # load native application
manifest.json   # native application's manifest file
install.bat     # install script
uninstall.bat   # uninstall script

# Linux or OSX
manifest.json   # native application's manifest file
install.sh      # install script
uninstall.sh    # uninstall script
```


