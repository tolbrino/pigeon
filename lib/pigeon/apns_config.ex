defmodule Pigeon.APNSConfig do
  @module """
    Provides configuration helper functions to other APNS functionality.
  """

  def connect_socket_options(cert, key) do
    options = [
      cert,
      key,
      {:password, ''},
      {:packet, 0},
      {:reuseaddr, true},
      {:active, true},
      :binary,
    ]
    if Application.get_env(:pigeon, :apns_2197) do
      [{:port, 2197} | options]
    else
      options
    end
  end

  def ssl_config(config) do
    %{
      cert:     cert(Map.get(config, :cert)),
      certfile: file_path(Map.get(config, :cert)),
      key:      key(Map.get(config, :key)),
      keyfile:  file_path(Map.get(config, :key)),
      mode:     Map.get(config, :mode, :dev),
    }
  end

  #
  # INTERNAL FUNCTIONS
  #

  defp file_path(nil), do: nil
  defp file_path(path) when is_binary(path) do
    cond do
      :filelib.is_file(path) -> Path.expand(path)
      true -> nil
    end
  end
  defp file_path({app_name, path}) when is_atom(app_name),
    do: Path.expand(path, :code.priv_dir(app_name))

  defp cert({_app_name, _path}), do: nil
  defp cert(nil), do: nil
  defp cert(bin) do
    case :public_key.pem_decode(bin) do
      [{:Certificate, cert, _}] -> cert
      _ -> nil
    end
  end

  defp key({_app_name, _path}), do: nil
  defp key(nil), do: nil
  defp key(bin) do
    case :public_key.pem_decode(bin) do
      [{:RSAPrivateKey, key, _}] -> {:RSAPrivateKey, key}
      _ -> nil
    end
  end

end
