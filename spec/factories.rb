FactoryBot.define do
  factory :user do
    email { 'foo@bar.com' }
    password { 'password' }
  end
end

FactoryBot.define do
  factory :project do
    title { 'Simple Project' }
    description { 'A really super simple thing' }
  end
end
