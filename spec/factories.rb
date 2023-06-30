# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    email
    password { 'password' }
  end

  factory :project do
    title { 'Simple Project' }
    description { 'A really super simple thing' }
    user

    trait :invalid do
      title { nil }
    end
  end

  factory :section do
    name { 'simple section' }
    project

    trait :invalid do
      name { nil }
    end
  end

  factory :task do
    name { 'simple task' }
    details { 'complicated details' }
    project
    section

    trait :invalid do
      name { nil }
    end
  end
end
