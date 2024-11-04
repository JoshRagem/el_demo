defmodule Whc.SitesTest do
  use Whc.DataCase

  alias Whc.Sites

  describe "whcsites" do
    alias Whc.Sites.Site

    import Whc.SitesFixtures

    @invalid_attrs %{name_en: nil}

    test "list_whcsites/0 returns all whcsites" do
      site = site_fixture()
      assert Sites.list_whcsites() == [site]
    end

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert Sites.get_site!(site.id) == site
    end

    test "create_site/1 with valid data creates a site" do
      valid_attrs = %{name_en: "some name_en"}

      assert {:ok, %Site{} = site} = Sites.create_site(valid_attrs)
      assert site.name_en == "some name_en"
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(@invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      update_attrs = %{name_en: "some updated name_en"}

      assert {:ok, %Site{} = site} = Sites.update_site(site, update_attrs)
      assert site.name_en == "some updated name_en"
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(site, @invalid_attrs)
      assert site == Sites.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = Sites.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Sites.change_site(site)
    end
  end
end
