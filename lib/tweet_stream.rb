class TweetStreamThread
  def initialize(bot)
    @bot = bot
  end

  def start
    TweetStream::Client.new.userstream do |status, client|
      client.stop if @bot.quitting
      @bot.channel_manager.each do |channel|
        channel.msg "[@\00303#{status.user.screen_name}\003] #{status.text}"
      end
    end
  end
end
