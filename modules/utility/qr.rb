# Copyright Erisa Komuro (Seriel), Spotlight 2016-2017

module YuukiBot
  module Utility

    require 'rqrcode'
    require 'pomf.rb'

    $cbot.add_command(:qr,
      code: proc { |event, args|
        tmp_path = "#{Dir.pwd}/tmp/qr.png"
        content = args.join(' ')
        # "Sanitize" qr code content
        if content.length > 1000
          event.respond("#{YuukiBot.config['emoji_error']} QR codes have a limit of 1000 characters. You went over by #{content.length - 1000}!")
          next
        end
        qrcode = RQRCode::QRCode.new(content)
        FileUtils.mkdir("#{Dir.pwd}/tmp/") unless File.exist?("#{Dir.pwd}/tmp/")
        FileUtils.rm(tmp_path) if File.exist?(tmp_path)
        png = qrcode.as_png(
            file: tmp_path # path to write
        )
        url = Pomf.upload_file(tmp_path)
        event.channel.send_embed do |embed|
          embed.colour = 0x74f167
          embed.url = "https://a.pomf.cat/#{url}"
        
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://a.pomf.cat/#{url}")
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "QR Code Generated by #{event.user.distinct}:", icon_url: Helper.avatar_url(event.user))
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Disclaimer: This QR Code is user-generated content.")
        
          embed.add_field(name: "QR Content:", value: "```#{content}```")
          embed.add_field(name: "QR Code:", value: "** **")
        end
      },
      min_args: 1,
      catch_errors: true
    )

  end
end