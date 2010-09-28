# by using the symbol ':user' we get Factory Girl to simulate the User model.

Factory.define :user do |user|
  user.name "Mike Kołolski"
  user.email "m.kololski@wp.pl"
  user.password "foobar"
  user.password_confirmation "foobar"
end
