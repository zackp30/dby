#!/usr/bin/env ruby
require 'rubygems' # Compatability.
require 'yaml' # Parsing repo files.
require 'parseconfig' # Parsing config files.
require 'open-uri' # Downloading repo files.
require 'colorize' # Colouring terminal output.
require 'commander/import' # Command parsing.
require 'terminal-table' # Clues in the name.
module DBY

  class DBYInit
    # Initialize ALL the things!
    Dir.mkdir("#{Dir.home}/.dby") if not Dir.exists?("#{Dir.home}/.dby")
    Dir.mkdir("#{Dir.home}/.dby/pkg.index") if not Dir.exists?("#{Dir.home}/.dby/pkg.index")
    Dir.mkdir("#{Dir.home}/.dby/pkgs") if not Dir.exists?("#{Dir.home}/.dby/pkgs")
  end
  class DBYConfig
    # Parse configuration.
    def initialize
      @confloc = "#{Dir.home}/.dby.conf"
    end
    def parse
      dbyconfig_exists = true if (File.exists?(@confloc) && File.size(@confloc) != 0)
      @config = ParseConfig.new(@confloc) if dbyconfig_exists
    end

    def init_conf
      # Create initial config file.
      dbyconffile = File.new(@confloc, 'w')
      dbyconffile.write("[repos]
zack = http://zackp30.tk/stuff/repos")
      dbyconffile.close
    end
    def writeconf
      conf = File.open(@confloc, 'w')
      @config.write(conf)
      conf.close
    end
    def valconf
      parse.validate_config
    end
    class Run_Le_Stuff
      DBY::DBYConfig.new.init_conf if not File.exists?("#{Dir.home}/.dby.conf")
      DBY::DBYConfig.new.parse
    end

  end


  class Repo
    def initialize
      @conf = DBY::DBYConfig.new
    end

    def add(name, url)
      @conf.parse['repos'][:"#{name}"] = "#{url}"
      @conf.writeconf
    end

    def remove(name)
      @conf.parse['repos'][:"#{name}"] = 'false'
      @conf.writeconf
    end
    def update
      @table = []
      @conf.parse['repos'].each do |f|
        begin
          repo = File.new("#{Dir.home}/.dby/pkg.index/#{f[0]}.yml", 'w+')
          repo.write(open("#{f[1]}/pkgs.yml").read)
          le = 0
          repo.close
          YAML.load(File.read("#{Dir.home}/.dby/pkg.index/#{f[0]}.yml"))['packages'].each { le += 1 }
          @table << [f[0], le]
        rescue
          puts "#{f[1]} (repo name #{f[0]}) no longer seems to contain a pkgs.yml file.".colorize(:red).underline
          repo.close
        end
      end
      begin
        @table2 =  Terminal::Table.new :headings => ['Repo', 'Packages'], :rows => @table
        @table2.style = {:border_y => "│", :border_x => "─", :border_i => "+"}
        puts @table2
      rescue
        return
      end
    end
  end

  class Package

    def initialize
      @conf = DBYConfig.new
    end
    def install(name)
      repo_loc = "#{Dir.home}/.dby/pkg.index"
      @conf.parse['repos'].each do |f|
        if YAML.load(File.read("#{repo_loc}/#{f[0]}.yml"))['packages'][name]
          @is_contained_in = f[1]
        end
      end
      le = File.new("#{Dir.home}/.dby/pkgs/#{name}", 'w')
      le.write(open("#{@is_contained_in}/pkgs/#{name}").read)
      le.close
    end

  end

  class CLI
    @repo = Repo.new
    @config2 = DBYConfig.new
    @package = Package.new
    program :version, '0.0.1'
    program :description, 'Personal program management.'
    command :'repo add' do |c|
      c.syntax = 'dby repo add <REPO NAME> <URL>'
      c.summary = 'Adds a new repo with REPO NAME and URL.'
      c.action do |args, options|
        name = args[0] || abort('You did not specify a name.')
        url = args[1] || abort('You did not specify an URL.')
        @repo.add(name, url)
      end
    end
    command :'repo remove' do |c|
      c.syntax = 'dby repo remove <REPO NAME>'
      c.summary = 'Removes a repo which mathces REPO NAME.'
      c.action do |args, options|
        name = args[0] || abort('You did not specify a name.')
        @repo.remove(name) 
      end
    end
    command :'repo update' do |c|
      c.syntax = 'dby repo update'
      c.summary = 'Updates repo/package index.'
      c.action do |args, options|
        @repo.update
      end
    end
    command :'config validate' do |c|
      c.syntax =  'dby config validate'
      c.summary = 'Validates configuration.'
      c.action do |args, options|
        @config2.valconf
      end
    end
    command :'pkg install' do |c|
      c.syntax = 'dby pkg install <PKG NAME>'
      c.summary = 'Installs package.'
      c.action do |args, options|
        package = args[0] || abort('You did not specify a PKG NAME.')
        @package.install(package)
      end
    end
  end
end
