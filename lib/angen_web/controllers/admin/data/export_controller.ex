defmodule AngenWeb.Admin.Data.ExportController do
  use AngenWeb, :controller

  plug AngenWeb.UserAuth, :ensure_authenticated
  plug AngenWeb.UserAuth, {:authorise, ~w(admin)}

  # {AngenWeb.UserAuth, :ensure_authenticated},
  #       {AngenWeb.UserAuth, {:authorise, ~w(admin)}

  @spec download(Plug.Conn.t(), map) :: Plug.Conn.t()
  def download(conn, %{"id" => id}) do
    file_path = "/tmp/#{id}.tar.gz"
    file_name = "match_export.tar.gz"
    content_type = "application/x-tar"

    conn
    |> put_resp_content_type(content_type)
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"#{file_name}\""
    )
    |> send_file(200, file_path)
  end
end
