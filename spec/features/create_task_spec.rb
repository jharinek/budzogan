require 'spec_helper'

describe 'Create Task' do
  let(:teacher) { create :teacher }

  before :each do
    login_as teacher
  end

  it 'shows new task form' do
    visit root_path

    click_link 'Nová úloha'

    expect(page).to have_content('Vyberte typ úlohy')
    expect(page).to have_content('Znenie úlohy')
    expect(page).to have_content('Ďalej')
  end
end