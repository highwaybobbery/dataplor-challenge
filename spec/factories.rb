FactoryBot.define do
  factory :bird do
    name { Faker::Name.unique.first_name }
    node { node }
  end

  factory :node do
    parent { nil }
  end
end
