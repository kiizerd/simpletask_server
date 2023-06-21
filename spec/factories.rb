# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    email { generate :email }
    password { 'password' }
  end

FactoryBot.define do
  factory :project do
    title { 'Simple Project' }
    description { 'A really super simple thing' }
  end
end
