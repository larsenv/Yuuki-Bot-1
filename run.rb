module YuukiBot
  require 'easy_translate'
  require 'haste'
  require 'open-uri'
  require 'redis'
  require 'redis-namespace'
  require 'json'
  
  if ENV['COMMANDRB_PATH'].nil?
    require 'commandrb'
  else
    puts '[INFO] Loading commandrb from Environment location.'
    require_relative "#{ENV['COMMANDRB_PATH']}/lib/commandrb"
  end

  if ENV['DISCORDRB_PATH'].nil?
    require 'discordrb'
  else
    puts '[INFO] Loading discordrb from Environment location.'
    require_relative "#{ENV['DISCORDRB_PATH']}/lib/discordrb"
  end
  require_relative 'modules/setup'
  require_relative 'modules/version'

  class CommandrbBot < CommandrbBot
    def is_owner?(id)
      if YuukiBot.config['master_owner'] == id
        true
      else
        begin
          JSON.parse(REDIS.get('owners')).include?(id)
        rescue
          false
        end
      end
    end
  end

  init_hash = YuukiBot.build_init

  $cbot = CommandrbBot.new(init_hash)

  module_dirs = %w(owner helper logging misc mod utility)
  module_dirs.each {|dir|
    Dir["modules/#{dir}/*.rb"].each { |r|
     require_relative r
     puts "Loaded: #{r}" if @config['verbose']
    }
  }

  require_relative 'modules/custom'
  puts 'Loaded custom commands!'

  # Load Extra Commands if enabled.
  if YuukiBot.config['extra_commands']
    puts 'Loading: Extra commands...' if @config['verbose']
    Dir['modules/extra/*.rb'].each { |r| require_relative r; puts "Loaded: #{r}" if @config['verbose'] }
  end
  orig_redis = Redis.new(host: YuukiBot.config['redis_host'], port: YuukiBot.config['redis_port'])
  REDIS = Redis::Namespace.new(YuukiBot.config['redis_namespace'], :redis => orig_redis )

  $cbot.bot.message do |event|
    Helper.calc_exp(event.user.id)
  end

  puts '>> Initial loading succesful!! <<'
  exit(1001) if YuukiBot.config['pretend_run']
  $uploader =  Haste::Uploader.new
  if YuukiBot.config['use_pry']
    $cbot.bot.run(true)
    require 'pry'
    binding.pry
  else
    puts 'Connecting to Discord....'
    $cbot.bot.run
  end
end
