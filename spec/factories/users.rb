FactoryBot.define do
  factory :user do
    first_name { 'test' }
    last_name { 'test' }
    sequence(:uin, (100_000_000..200_000_000).cycle, &:to_s)
    sequence(:email) { |n| "random#{n}@gmail.com" }
    password { '123456' }
    confirmed_at { Time.now }
    points { 0.0 }
    volunteer_hours { 0.0 }
  end
end
