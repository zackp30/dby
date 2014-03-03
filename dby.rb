#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'yaml'
require 'parseconfig'
require 'commander/import'
module DBY

  class DBYInit
    # Initialize ALL the things!
    Dir.mkdir("#{Dir.home}/.dby")
  end
  class DBYConfig
    # Parse configuration.
    def initialize
      @confloc = "#{Dir.home}/.dby.conf"
    end
    def parse
      dbyconfig_exists = true if (File.exists?(@confloc) && File.size(@confloc) != 0)
      @config = ParseConfig.new(@confloc) if dbyconfig_exists == true
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
      DBY::DBYConfig.new.init_conf if File.exists?("#{Dir.home}/.dby.conf") == false
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

  end
  class Package

    def install
      # TODO: Implement this!
      puts "TODO: Implement this."
      return 'E1'
    end

  end

  class CLI
    @repo = Repo.new
    @config2 = DBYConfig.new
    program :version, '0.0.1'
    program :description, 'Personal program management.'
     
    command :'repo add' do |c|
      c.syntax = 'dby repo add <REPO NAME> <URL>'
      c.summary = 'Adds a new repo with REPO NAME and URL.'
      c.action do |args, options|
        name = args[0] || abort('You did not specify a name.')
        url = args[1] || abort('Youd did not specify an URL.')
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
    command :'config validate' do |c|
      c.syntax =  'dby config validate'
      c.summary = 'Validates configuration.'
      c.action do |args, options|
        @config2.valconf
      end
    end
  end
end
