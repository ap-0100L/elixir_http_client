defmodule HttpClient.Services.HttpClientService do
  ##############################################################################
  ##############################################################################
  @moduledoc """
  ## Module
  """

  use Utils

  @supervisor_name HttpClient.Supervisor
  @transport_id HttpClient.CommonHttpClient
  @transport_name CommonFinch
  @query "select t.url, t.config from {#} as t where t.state_id = 'active'"

  ##############################################################################
  @doc """
  ## Function
  """
  def get_transport_name_() do
    @transport_name
  end

  ##############################################################################
  @doc """
  ## Function
  """
  def build_children_spec_list!(db_repo, table_name)
      when not is_atom(db_repo) or not is_bitstring(table_name),
      do:
        UniError.raise_error!(
          :CODE_WRONG_FUNCTION_ARGUMENT_ERROR,
          ["db_repo, table_name cannot be nil; db_repo must be an atom; table_name must be a string"]
        )

  def build_children_spec_list!(db_repo, table_name) do
    query = Utils.format_string_(@query, [table_name])
    {:ok, records} = db_repo.exec_query!(query)

    if records == :CODE_NOTHING_FOUND do
      UniError.raise_error!(:CODE_REST_API_CLIENTS_NOT_FOUND_ERROR, ["Rest API clients not found"])
    end

    finch_pools =
      Enum.reduce(
        records,
        %{
          :default => [
            size: 10,
            count: 5
          ]
        },
        fn item, accum ->
          %{url: url, config: config} = item
          Map.put(accum, url, config)
        end
      )

    result = [Supervisor.child_spec({Finch, name: @transport_name, pools: finch_pools}, id: @transport_id)]
    #    result = [{Finch, name: @transport_name, pools: finch_pools}]

    {:ok, result}
  end

  ##############################################################################
  @doc """
  ## Function
  """
  def start_transports!() do
    Logger.info("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] I will try start http clients")

    {:ok, db_repo} = get_app_env!(:db_repo)
    {:ok, table_name} = get_app_env!(:table_name)

    raise_if_empty!(@transport_name, :atom, "Wrong @transport_name value")
    raise_if_empty!(db_repo, :atom, "Wrong db_repo value")
    raise_if_empty!(table_name, :string, "Wrong table_name value")

    {:ok, child_spec} = build_children_spec_list!(@transport_name, db_repo, table_name)

    opts = [
      strategy: :one_for_one,
      name: @supervisor_name
    ]

    result = Utils.supervisor_start_link!(child_spec, opts)

    Logger.info("[#{inspect(__MODULE__)}][#{inspect(__ENV__.function)}] Rest api clients successfully started")

    result
  end

  ##############################################################################
  ##############################################################################
end
