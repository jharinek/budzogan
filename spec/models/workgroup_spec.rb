require 'spec_helper'

describe Workgroup do
  it 'has a valid factory' do
    workgroup = build :workgroup
    expect(workgroup).to be_valid
  end

  it 'requires correct name' do
    workgroup = build :workgroup, name:''
    expect(workgroup).not_to be_valid

    workgroup = build :workgroup, name: '?weird_chars!;,*'
    expect(workgroup).not_to be_valid

    workgroup = build :workgroup, name: '8.A class'
    expect(workgroup).to be_valid
  end
end
