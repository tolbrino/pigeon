defmodule Pigeon.APNS do
  @moduledoc """
    Defines publically-exposed Apple Push Notification Service (APNS) functions. For implementation
    see APNSWorker.
  """

  @doc """
    Sends a push over APNS.
  """
  @spec push(term(), Pigeon.APNS.Notification) :: none
  def push(service_id, notification), do: Pigeon.APNSWorker.push(service_id, notification)

  @doc """
    Sends a push over APNS.
  """
  @spec push(term(), Pigeon.APNS.Notification, (() -> none)) :: none
  def push(service_id, notification, on_response), do: Pigeon.APNSWorker.push(service_id, notification, on_response)

end
