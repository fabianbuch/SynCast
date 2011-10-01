class JoinPart
  include Cinch::Plugin

  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part
  listen_to :invite, method: :invited

  def initialize(*args)
    super

    @admins = config[:admins]
  end

  def check_user(user)
    user.refresh
    @admins.include?(user.user)
  end

  def join(m, channel)
    return unless check_user(m.user)
    Channel(channel).join
  end

  def part(m, channel)
    return unless check_user(m.user)
    channel ||= m.channel
    Channel(channel).part if channel
  end
  
  def invited(m)
    join(m, m.channel)
  end
end
