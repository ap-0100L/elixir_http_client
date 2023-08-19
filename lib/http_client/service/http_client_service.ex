defmodule HttpClient.Services.HttpClientService do
  ####################################################################################################################
  ####################################################################################################################
  @moduledoc """
  ## Module
  """

  use Utils


  alias HttpClient.Application, as: Application

  @transport_id HttpClient.CommonHttpClient
  @transport_name CommonFinch
  @query_all_active ~s"""
  select
    t.id,
    t.config,
    t.order,
    t.state_id
  from {#} as t
  where
    t.state_id = 'ACTIVE'
  order by t.order asc
  """

  ####################################################################################################################
  @doc """
  ## Function
  """
  def build_children_spec_list(db_repo, table_name, pools)
      when not is_atom(db_repo) or not is_bitstring(table_name) or not is_map(pools),
      do:
        UniError.raise_error!(
          :WRONG_FUNCTION_ARGUMENT_ERROR,
          ["db_repo, table_name, pools cannot be nil; db_repo must be an atom; table_name must be a string; pools must be a map"]
        )

  def build_children_spec_list(db_repo, table_name, pools) do
    Logger.warn("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] I will select http clients from [#{table_name}]")
    query = Utils.format_string(@query_all_active, [table_name])
    {:ok, records} = db_repo.exec_query(query)

    pools =
      if records == :NOT_FOUND do
        Logger.warn("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] I did not found any consumer")
        pools
      else
        _default = Map.fetch!(pools, :default)

        Enum.reduce(
          records,
          pools,
          fn item, accum ->
            [id, config, _order, _state_id] = item
            {:ok, config} = CodeUtils.string_to_code!(config)
            Map.put(accum, id, config)
          end
        )
      end

    result = Supervisor.child_spec({Finch, name: @transport_name, pools: pools}, id: @transport_id, restart: :transient) #:permanent

    Logger.warn("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] I got http clients [#{inspect(result)}]")
    {:ok, result}
  end

  ####################################################################################################################
  @doc """
  ## Function
  """
  def start_http_client() do
    Logger.info("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] I will try start http client")

    {:ok, db_repo} = get_app_env(:db_repo)
    {:ok, table_name} = get_app_env(:table_name)
    {:ok, pools} = get_app_env(:pools)
    raise_if_empty!(db_repo, :atom, "Wrong db_repo value")
    raise_if_empty!(table_name, :string, "Wrong table_name value")
    raise_if_empty!(pools, :map, "Wrong pools value")

    {:ok, child_spec} = build_children_spec_list(db_repo, table_name, pools)

    {:ok, pid} = DynamicSupervisorUtils.start_child(Application.get_dynamic_supervisor_name(), child_spec)

    Logger.info("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] Http client successfully started")

    {:ok, pid}
  end

  ####################################################################################################################
  @doc """
  ## Function
  """
  def stop_http_client(pid, reason \\ :normal, timeout \\ :infinity)

  def stop_http_client(pid, reason, timeout)
      when is_nil(pid) or not is_atom(reason) or (not is_atom(timeout) and not is_number(timeout)),
      do:
        UniError.raise_error!(
          :WRONG_FUNCTION_ARGUMENT_ERROR,
          ["reason, timeout cannot be nil; reason must be an atom; timeout must be an atom or number"]
        )

  def stop_http_client(pid, reason, timeout) do
    Logger.info("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] I will try stop http client")

    result = GenServerUtils.stop(pid, reason, timeout)

    Logger.info("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] Http client successfully stopped")

    result
  end

  ####################################################################################################################
  @doc """
  # Function.
  """
  def get_transport_name() do
    @transport_name
  end

  ####################################################################################################################
  ####################################################################################################################
end
