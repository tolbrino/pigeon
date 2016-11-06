defmodule Pigeon.Supervisor do
  @moduledoc """
    Supervises an APNSWorker, restarting as necessary.
  """
  use Supervisor
  require Logger

  alias Pigeon.{APNSConfig}

  #
  # EXTERNAL API
  #

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  #
  # Supervisor API
  #

  def init(:ok) do
    children = apns_children ++ adm_children
    supervise(children, strategy: :one_for_one)
  end

  #
  # INTERNAL FUNCTIONS
  #

  defp adm_children do
    cond do
      !adm_configured? ->
        []
      valid_adm_config?(adm_config) ->
        [worker(Pigeon.ADMWorker, [:adm_worker, adm_config], id: :adm_worker)]
      true ->
        Logger.error "Error starting :adm_worker. Invalid OAuth2 configuration."
        []
    end
  end

  defp apns_children do
    Enum.reduce(config_apns(), [], fn(c, acc) ->
      cond do
        !apns_keys?(c) ->
          acc
        valid_apns_config?(APNSConfig.ssl_config(c)) ->
          [worker(Pigeon.APNSWorker, [{:apns_worker, worker_id(c)}, APNSConfig.ssl_config(c)], id: worker_id(c)) | acc]
        true ->
          Logger.error ~s(Error reading :apns_worker #{worker_id(c)} configuration.
                          Invalid mode/cert/key configuration.)
          acc
      end
    end)
  end

  defp worker_id(config), do: Map.get(config, :id)

  defp config_apns, do: Application.get_env(:pigeon, :apns, [])

  defp config_adm_client_id, do: Application.get_env(:pigeon, :adm_client_id)
  defp config_adm_client_secret, do: Application.get_env(:pigeon, :adm_client_secret)


  defp apns_keys?(config) do
    mode = Map.get(config, :mode)
    cert = Map.get(config, :cert)
    key = Map.get(config, :key)
    !is_nil(mode) && !is_nil(cert) && !is_nil(key)
  end

  defp valid_apns_config?(config) do
    valid_mode? = (config[:mode] == :dev || config[:mode] == :prod)
    valid_cert? = !is_nil(config[:cert] || config[:certfile])
    valid_key? = !is_nil(config[:key] || config[:keyfile])
    valid_mode? and valid_cert? and valid_key?
  end

  def adm_config do
    %{
      client_id: config_adm_client_id,
      client_secret: config_adm_client_secret
    }
  end

  def adm_configured? do
    client_id = Application.get_env(:pigeon, :adm_client_id)
    client_secret = Application.get_env(:pigeon, :adm_client_secret)
    !is_nil(client_id) and !is_nil(client_secret)
  end

  def valid_adm_config?(config) do
    valid_client_id? = is_binary(config[:client_id]) and String.length(config[:client_id]) > 0
    valid_client_secret? = is_binary(config[:client_secret]) and String.length(config[:client_secret]) > 0
    valid_client_id? and valid_client_secret?
  end

  def push(:apns, notification),
    do: GenServer.cast(:apns_worker, {:push, :apns, notification})
  def push(:adm, notification),
    do: GenServer.cast(:adm_worker, {:push, :adm, notification})
  def push(service, _notification),
    do: Logger.error "Unknown service #{service}"

  def push(:apns, notification, on_response),
    do: GenServer.cast(:apns_worker, {:push, :apns, notification, on_response})
  def push(:adm, notification, on_response),
    do: GenServer.cast(:adm_worker, {:push, :adm, notification, on_response})
  def push(service, _notification, _on_response),
    do: Logger.error "Unknown service #{service}"

  def handle_cast(:stop , state), do: { :noreply, state }

end
