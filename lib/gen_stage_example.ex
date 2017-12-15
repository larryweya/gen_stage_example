defmodule GenStageExample do

  defmodule Store do
    @moduledoc """
    Simulates a data store that our producer will data from
    """
    use Agent

    def start_link(_opts) do
      Agent.start_link(__MODULE__, :init, [], name: __MODULE__)
    end

    def init() do
      []
    end

    def push(agent, values) when is_list(values) do
      Agent.update agent, fn state ->
        state ++ values
      end
    end

    def push(agent, value) do
      push(agent, [value])
    end

    def pop(agent, count) when count > 0 do
      Agent.get_and_update agent, fn state -> 
        # simulate db call taking upto 100ms
        :timer.sleep :rand.uniform(100)
        Enum.split(state, count)
      end
    end

    def pop(_agent, _count) do
      []
    end

    def get(agent) do
      Agent.get agent, fn state ->
        state
      end
    end

  end
  
  defmodule Producer do
    use GenStage
    
    require Logger
    
    def start_link() do
      GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
    end
  
    def init(:ok) do
      Process.send_after self(), :poll, 1_000
      {:producer, {0, []}}
    end
  
    def handle_demand(demand, {pending_demand, buffered_events}) when demand > 0 do
      Logger.info "Producer.handle_demand: demand = #{demand}, pending_demand = #{pending_demand}, buffered_events = #{inspect buffered_events}"
      total_demand = demand + pending_demand
      process_demand(total_demand, buffered_events)
    end

    def handle_info(:poll, {pending_demand, buffered_events}) do
      # match on number of events we need to fulfill demand
      new_events = case max 0, pending_demand - length(buffered_events) do
        0 ->
          buffered_events
        max_required_events ->
          # pop just enough events to fulfill demand, capped at 10 events
          new_events = GenStageExample.Store.pop GenStageExample.Store, min(10, max_required_events)
          buffered_events ++ new_events
      end
      Process.send_after self(), :poll, 2_000
      process_demand(pending_demand, new_events)
    end

    # common function to handle demand by buffering pending demand and events
    defp process_demand(total_demand, events) do
      # get max 0, total_demand - length(buffered_events) events from Store
      # get max total demand events
      {events_to_send, new_buffered_events} = Enum.split events, total_demand
      new_pending_demand = case events_to_send do
        [] ->
          # if no events to send, return total demand
          total_demand
        _ ->
          # otherwise return total_demand - length(events_to_send)
          max 0, total_demand - length(events_to_send)
      end
      Logger.info "Producer.process_demand returning: new_pending_demand = #{new_pending_demand}, new_buffered_events = #{inspect new_buffered_events}"
      {:noreply, events_to_send, {new_pending_demand, new_buffered_events}}
    end

  end

  defmodule Consumer do
    use GenStage

    require Logger
    
    def start_link() do
      GenStage.start_link(__MODULE__, :ok)
    end
  
    def init(:ok) do
      {:consumer, :the_state_does_not_matter, subscribe_to: [{GenStageExample.Producer, max_demand: 10}]}
    end
  
    def handle_events(events, _from, state) do
      Logger.info "Consumer.handle_events<#{inspect self()}>: events = #{inspect Enum.map(events, &to_string(&1))}"
      # We are a consumer, so we would never emit items.
      {:noreply, [], state}
    end
  end
end
