class TweetStreamThread
  def initialize(bot)
    @bot = bot
  end

  def start
    client = TweetStream::Client.new

    client.on_timeline_status do |status|
      client.stop if @bot.quitting
      @bot.channel_manager.each do |channel|
        channel.msg "[@\00303#{status.user.screen_name}\003] #{status.text}"
      end
    end

    client.userstream
  end
end
