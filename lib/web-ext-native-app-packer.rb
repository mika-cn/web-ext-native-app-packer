
require 'ostruct'

module WebExtNativeAppPacker

  TARGET_PATH_OSX = {
    chrome: {
      system: '/Library/Google/Chrome/NativeMessagingHosts',
      user: '$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts'
    },
    chromium: {
      system: '/Library/Application Support/Chromium/NativeMessagingHosts',
      user: '$HOME/Library/Application Support/Chromium/NativeMessagingHosts'
    },
    firefox: {
      system: '/Library/Application Support/Mozilla/NativeMessagingHosts',
      user: '$HOME/Library/Application Support/Mozilla/NativeMessagingHosts'
    }
  }

  TARGET_PATH_LINUX = {
    chrome: {
      system: '/etc/opt/chrome/native-messaging-hosts',
      user: '$HOME/.config/google-chrome/NativeMessagingHosts'
    },
    chromium: {
      system: '/etc/chromium/native-messaging-hosts',
      user: '$HOME/.config/chromium/NativeMessagingHosts'
    },
    firefox: {
      system: '/usr/lib64/mozilla/native-messaging-hosts',
      user: '$HOME/.mozilla/native-messaging-hosts'
    }
  }

  TARGET_PATH_WINDOWS = {
    chrome: {
      system: 'HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\NativeMessagingHosts',
      user: 'HKEY_CURRENT_USER\SOFTWARE\Google\Chrome\NativeMessagingHosts'
    },
    chromium: {
      system: 'HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\NativeMessagingHosts',
      user: 'HKEY_CURRENT_USER\SOFTWARE\Google\Chrome\NativeMessagingHosts'
    },
    firefox: {
      system: 'HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\NativeMessagingHosts',
      user: 'HKEY_CURRENT_USER\SOFTWARE\Mozilla\NativeMessagingHosts'
    }
  }

  def self.perform(input)
    render_manifest(input)
    render_app_loader(input)
    render_unix_like_install_script(input)
    render_unix_like_uninstall_script(input)
    render_windows_install_script(input)
    render_windows_uninstall_script(input)
    copy_project_file(input)
    zip_folds(input)
  end

  def self.copy_project_file(input)
    input_path = File.join(input.project_dir, '*')
    each_item do |platform, browser_name|
      output_path = File.join(
        input.output_dir,
        [platform, browser_name].join('-'),
      )
      `cp -r #{input_path} #{output_path}`
    end
  end

  def self.zip_folds(input)
    each_item do |platform, browser_name|
      name = input.app_name.gsub('_', '-').gsub('.', '-')
      input_fold = File.join(
        input.output_dir,
        [platform, browser_name].join('-'),
      )
      archive_path = File.join(
        input.output_dir,
        [[name, platform, browser_name].join('-'), 'zip'].join('.')
      )
      pack_sh = File.expand_path('../pack.sh', __FILE__)
      `#{pack_sh} #{input_fold} #{archive_path}`
    end
  end

  def self.render_unix_like_install_script(input)
    render_script(input,
      erb_path: File.expand_path('../template/install-unix-like.sh.erb', __FILE__),
      platforms: ['osx', 'linux'],
      filename: 'install.sh')
  end

  def self.render_unix_like_uninstall_script(input)
    render_script(input,
      erb_path: File.expand_path('../template/uninstall-unix-like.sh.erb', __FILE__),
      platforms: ['osx', 'linux'],
      filename: 'uninstall.sh')
  end

  def self.render_windows_install_script(input)
    render_script(input,
      erb_path: File.expand_path('../template/install-windows.bat.erb', __FILE__),
      platforms: ['windows'],
      filename: 'install.bat')
  end

  def self.render_windows_uninstall_script(input)
    render_script(input,
      erb_path: File.expand_path('../template/uninstall-windows.bat.erb', __FILE__),
      platforms: ['windows'],
      filename: 'uninstall.bat')
  end

  def self.render_script(input, erb_path:, platforms:, filename:)
    each_item do |platform, browser_name|
      if platforms.include?(platform)
        target_path = get_target_path(platform, browser_name)
        v = OpenStruct.new({
          app_name: input.app_name,
          app_path: input.app_path,
          target_path_system: target_path[:system],
          target_path_user: target_path[:user]
        })
        out_path = File.join(
          input.output_dir,
          [platform, browser_name].join('-'),
          filename
        )
        Helper.render(v, erb_path, out_path)
        if out_path.end_with?('.sh')
          `chmod a+x #{out_path}`
        end
      end
    end
  end

  def self.get_target_path(platform, browser_name)
    dict = \
      case platform
      when 'osx'    then TARGET_PATH_OSX
      when 'linux'  then TARGET_PATH_LINUX
      when 'windows'then TARGET_PATH_WINDOWS
      end
    dict[browser_name.to_sym]
  end


  def self.render_app_loader(input)
    erb_path = File.expand_path('../template/app-loader.bat.erb', __FILE__)
    each_item do |platform, browser_name|
      if platform == 'windows'
        v = OpenStruct.new({
          execute_cmd: input.execute_cmd,
          app_path: input.app_path
        })
        out_path = File.join(
          input.output_dir,
          [platform, browser_name].join('-'),
          'app_loader.bat'
        )
        Helper.render(v, erb_path, out_path)
      end
    end
  end

  def self.render_manifest(input)
    erb_path = File.expand_path('../template/manifest.json.erb', __FILE__)
    each_item do |platform, browser_name|
      v = OpenStruct.new({
        app_name: input.app_name,
        app_description: input.app_description
      })
      if browser_name == 'firefox'
        v.white_list_key = 'allowed_extensions'
        v.extension_identify = input['extension_id']
      else
        v.white_list_key = 'allowed_origins'
        v.extension_identify = input['extension_origin']
      end

      if platform == 'windows'
        v.app_path = 'app_loader.bat'
      else
        v.app_path = 'APP_PATH'
      end

      out_path = File.join(
        input.output_dir,
        [platform, browser_name].join('-'),
        'manifest.json'
      )
      Helper.render(v, erb_path, out_path)
    end
  end

  def self.each_item
    ['osx', 'linux', 'windows'].each do |platform|
      ['chrome', 'chromium', 'firefox'].each do |browser_name|
        yield platform, browser_name
      end
    end
  end

  module Helper
    require 'erb'
    require 'fileutils'
    def self.render(v, erb_path, out_path)
      mkdir(out_path)
      @v = v
      b = binding
      erb = ::ERB.new(File.new(erb_path).read)
      File.open(out_path, 'w') do |f|
        f.write erb.result(b)
      end
    end

    def self.mkdir(out_path)
      dir = out_path[0, out_path.rindex('/')]
      unless File.exist?(dir)
        FileUtils.mkdir_p(dir)
      end
    end
  end

end
