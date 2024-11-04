defmodule Whc.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "whcsites" do
    field(:uid, :integer)
    field(:name_en, :string)
    field(:name_fr, :string)
    field(:short_description_en, :string)
    field(:short_description_fr, :string)
    field(:justification_en, :string)
    field(:justification_fr, :string)
    field(:date_inscribed, :string)
    field(:danger, :string)
    field(:danger_list, :string)
    field(:longitude, :string)
    field(:latitude, :string)
    field(:states_name_en, :string)
    field(:states_name_fr, :string)
    field(:region_en, :string)
    field(:region_fr, :string)

  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [
      :uid,
      :name_en,
      :name_fr,
      :short_description_en,
      :short_description_fr,
      :justification_en,
      :justification_fr,
      :date_inscribed,
      :danger,
      :danger_list,
      :longitude,
      :latitude,
      :states_name_en,
      :states_name_fr,
      :region_en,
      :region_fr
    ])
    |> validate_required([
      :name_en,
      :name_fr,
      :short_description_en,
      :short_description_fr,
      :justification_en,
      :justification_fr,
      :date_inscribed,
      :longitude,
      :latitude,
      :states_name_en,
      :states_name_fr,
      :region_en,
      :region_fr
    ])
  end
end
