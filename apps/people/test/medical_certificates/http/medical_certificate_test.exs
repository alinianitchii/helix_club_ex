defmodule People.Http.PersonTest do
  use People.DataCase
  use People.Http.ConnCase

  @medical_certificate_fixture %{
    "holder_id" => UUID.uuid4(),
    "holder_name" => "Ciccio",
    "holder_surname" => "Pasticcio"
  }

  defp do_api_call(method, path, data \\ "") do
    conn = build_conn(method, path, data)

    decoded_resp_body =
      case conn.resp_body != "" do
        true -> Jason.decode!(conn.resp_body)
        false -> nil
      end

    {:ok, %{status: conn.status, decoded: decoded_resp_body}}
  end

  describe "POST /medical-certificates" do
    test "registers a new medical certificate" do
      {:ok, resp} =
        do_api_call(:post, "/medical-certificates", @medical_certificate_fixture)

      assert resp.status == 201
      assert Map.get(resp.decoded, "id") != nil
    end
  end

  describe "GET /medical-certificates/:id" do
    test "retrieves a medical certificate by id" do
      {:ok, resp} =
        do_api_call(:post, "/medical-certificates", @medical_certificate_fixture)

      %{"id" => id} = resp.decoded
      {:ok, resp} = do_api_call(:get, "/medical-certificates/#{id}")

      assert resp.status == 200
      assert resp.decoded["id"] == id
      assert resp.decoded["holder_id"] == @medical_certificate_fixture["holder_id"]
      assert resp.decoded["holder_name"] == @medical_certificate_fixture["holder_name"]
      assert resp.decoded["holder_surname"] == @medical_certificate_fixture["holder_surname"]
      assert resp.decoded["request_date"] == Date.to_string(Date.utc_today())
      assert resp.decoded["status"] == "unknown"
    end

    test "returns 404 for non-existent person" do
      non_existent_id = UUID.uuid4()

      {:ok, resp} = do_api_call(:get, "/people/#{non_existent_id}")

      assert resp.status == 404
    end
  end
end
