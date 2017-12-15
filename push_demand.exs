defmodule GenStageExample.PushDemand do
  require Logger

  @sleep_time 3_000
  def run() do
    Logger.info "GenStageExample.Store.push 1..8"
    GenStageExample.Store.push GenStageExample.Store, Enum.into(1..8, [])
    Logger.info "GenStageExample.PushDemand sleep"
    :timer.sleep(@sleep_time)
    Logger.info "GenStageExample.Store.push 9..23"
    GenStageExample.Store.push GenStageExample.Store, Enum.into(9..23, [])
    Logger.info "GenStageExample.PushDemand sleep"
    :timer.sleep(@sleep_time)
    Logger.info "GenStageExample.Store.push 24..26"
    GenStageExample.Store.push GenStageExample.Store, Enum.into(24..26, [])
    Logger.info "GenStageExample.PushDemand sleep"
    :timer.sleep(@sleep_time)
    Logger.info "GenStageExample.Store.push 27..51"
    GenStageExample.Store.push GenStageExample.Store, Enum.into(27..51, [])
  end

end

GenStageExample.PushDemand.run
