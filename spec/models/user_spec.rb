require 'spec_helper'

describe User do
  let(:user) { create :user }

  it 'has a valid factory' do
    user = build :user
    expect(user).to be_valid
  end

  it 'requires correct login' do
    user = build :user, login: ''
    expect(user).not_to be_valid

    user = build :user, login: 'la-la'
    expect(user).not_to be_valid

    user = build :user, login: 'user1'
    expect(user).to be_valid
  end

  it 'requires correct nick' do
    user = build :user, nick: ''
    expect(user).not_to be_valid

    user = build :user, nick: 'invalid-nick!'
    expect(user).not_to be_valid

    user = build :user, nick: 'nickName'
    expect(user).to be_valid
  end

  it 'requires correct first name' do
    user = build :user, first: ''
    expect(user).not_to be_valid

    user = build :user, first: 'dave'
    expect(user).not_to be_valid

    user = build :user, first: 'Dave'
    expect(user).to be_valid
  end

  it 'requires correct last name' do
    user = build :user, last: ''
    expect(user).not_to be_valid

    user = build :user, last: 'gorgeous'
    expect(user).not_to be_valid

    user = build :user, last: 'Gorgeous'
    expect(user).to be_valid
  end

  it 'requires correct email' do
    user = build :user, email: ''
    expect(user).not_to be_valid

    user = build :user, email: 'student.school.com'
    expect(user).not_to be_valid

    user = build :user, email: 'student@school.com'
    expect(user).to be_valid
  end

  it 'sets nick according to login on create' do
    user = build :user

    expect(user.login).to eql(user.nick)
  end

  context 'when login is set' do
    it 'requires nick' do
      user = build :user, login: 'joe'

      expect(user).to      be_valid
      expect(user.nick).to eql('joe')
    end
  end

  # TODO ask smolnar
  # context 'when login is not set' do
  #   it 'does not require nick' do
  #     user = build :user, login: nil
  #
  #     expect(user).not_to        be_valid
  #     expect(user.errors).to     include(:login)
  #     expect(user.errors).not_to include(:nick)
  #   end
  # end

  describe '.create_without_confirmation!' do
    it 'creates user without need of confirmation' do
      user_params = { first: 'Joe', last: 'Doe', login: 'user', email: 'user@example.com', password: 'password' }
      user = User.create_without_confirmation!(user_params)

      expect(user.login).to                  eq('user')
      expect(user.email).to                  eq('user@example.com')
      expect(user.encrypted_password).not_to be_nil
      expect(user).to                        be_confirmed
    end
  end

  describe '.find_first_by_auth_conditions' do
    context 'with login' do
      it 'finds user by login' do
        u = User.find_first_by_auth_conditions(login: user.login)
        expect(u).to eql(user)

        u = User.find_first_by_auth_conditions(login: user.login.upcase)
        expect(u).to eql(user)
      end
    end

    context 'with email' do
      it 'find user by email' do
        u = User.find_first_by_auth_conditions(email: user.email)
        expect(u).to eql(user)
      end
    end
  end
end
