defmodule People.Domain.PersonFullNameTest do
  use ExUnit.Case

  alias People.Domain.FullNameValueObject

  describe "create/2" do
    test "returns success with valid name and surname" do
      assert {:ok, full_name} = FullNameValueObject.create("Ciccio", "Pasticcio")
      assert full_name.name == "Ciccio"
      assert full_name.surname == "Pasticcio"
    end

    test "capitalizes first letter and downcases the rest" do
      assert {:ok, full_name} = FullNameValueObject.create("ciccio", "PASTICCIO")
      assert full_name.name == "Ciccio"
      assert full_name.surname == "Pasticcio"
    end

    test "handles mixed case input" do
      assert {:ok, full_name} = FullNameValueObject.create("CiCcIo", "PaStIcCiO")
      assert full_name.name == "Ciccio"
      assert full_name.surname == "Pasticcio"
    end

    test "trims whitespace" do
      assert {:ok, full_name} = FullNameValueObject.create("  Ciccio  ", "  Pasticcio  ")
      assert full_name.name == "Ciccio"
      assert full_name.surname == "Pasticcio"
    end

    test "returns error for invalid characters in name" do
      assert {:error, error} = FullNameValueObject.create("Ciccio4348&", "Pasticcio")
      assert error.code == :invalid_characters
      assert error.message == "Name contains invalid characters"
    end

    test "returns error for invalid characters in surname" do
      assert {:error, error} = FullNameValueObject.create("Ciccio", "Pasticcio345/")
      assert error.code == :invalid_characters
      assert error.message == "Surname contains invalid characters"
    end

    test "returns error for empty string name" do
      assert {:error, error} = FullNameValueObject.create("", "Pasticcio")
      assert error.code == :empty_value
      assert error.message == "Name cannot be empty"
    end

    test "returns error for empty string surname" do
      assert {:error, error} = FullNameValueObject.create("Ciccio", "")
      assert error.code == :empty_value
      assert error.message == "Surname cannot be empty"
    end

    test "returns error for nil name" do
      assert {:error, error} = FullNameValueObject.create(nil, "Pasticcio")
      assert error.code == :empty_value
      assert error.message == "Name cannot be empty"
    end

    test "returns error for nil surname" do
      assert {:error, error} = FullNameValueObject.create("Ciccio", nil)
      assert error.code == :empty_value
      assert error.message == "Surname cannot be empty"
    end

    test "handles single character names" do
      assert {:ok, full_name} = FullNameValueObject.create("J", "Doe")
      assert full_name.name == "J"
      assert full_name.surname == "Doe"
    end

    test "handles names with numbers" do
      assert {:ok, full_name} = FullNameValueObject.create("John2", "Doe3")
      assert full_name.name == "John2"
      assert full_name.surname == "Doe3"
    end

    test "handles names with spaces" do
      assert {:ok, full_name} = FullNameValueObject.create("John Paul", "Van Der Beek")
      assert full_name.name == "John Paul"
      assert full_name.surname == "Van Der Beek"
    end
  end
end
