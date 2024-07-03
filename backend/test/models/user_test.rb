# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test 'should not save duplicate email' do
    User.create(name: 'name', email: 'unique@email.com', password: 'pass')
    duplicate_user = User.new(name: 'another name', email: 'unique@email.com', password: 'another pass')

    assert_not duplicate_user.valid?, 'Duplicate email should not be valid'
    assert_includes duplicate_user.errors[:email], 'already exists'
  end

  test 'should not save duplicate email case insensitive' do
    User.create(name: 'name', email: 'unique@email.com', password: 'pass')
    duplicate_user = User.new(name: 'another name', email: 'uNIqUE@email.com', password: 'another pass')

    assert_not duplicate_user.valid?, 'Duplicate email should not be valid'
    assert_includes duplicate_user.errors[:email], 'already exists'
  end

  test 'should create a non-deletable Cash account upon User creation' do
    u = User.create(name: 'name', email: 'test@gmail.com', password: 'pass')
    assert_includes u.accounts.map(&:name), 'Cash', 'Cash account not created on User creation'
    assert_not u.accounts.find_by(name: 'Cash').deletable, 'Cash account marked as deletable'
  end
end
