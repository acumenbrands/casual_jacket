require 'spec_helper'

describe CasualJacket do

  let(:handle)  { 'test-import' }
  let(:headers) { 'Group Code,UPC Code' }
  let(:row1)    { 'SCHWA,123456' }
  let(:row2)    { 'FOO,654321' }

  let(:csv_string) { "#{headers}\n#{row1}\n#{row2}" }
  let(:csv_file)   { StringIO.new(csv_string) }

  let(:legend) { { 'Group Code' => 'sku', 'UPC Code' => 'upc_code' } }

  let(:group_header) { 'Group Code' }

  let(:operations)           { CasualJacket.operations_for(handle) }
  let(:operation_attributes) { operations.map(&:attributes) }
  let(:operation_groups)     { operations.map(&:group) }

  let(:expected_attributes1) do
    {
      'sku'      => 'SCHWA',
      'upc_code' => '123456'
    }
  end

  let(:expected_attributes2) do
    {
      'sku'      => 'FOO',
      'upc_code' => '654321'
    }
  end

  let(:expected_groups) { ['SCHWA', 'FOO'] }

  before do
    CasualJacket.redis_connection.flushall
    CasualJacket.cache_operations(handle, csv_file, legend, group_header)
  end

  it 'has produced the correct count of operations' do
    expect(operations.count).to eq(2)
  end

  it 'has produced an operation representing the first row from the csv' do
    expect(operation_attributes).to include(expected_attributes1)
  end

  it 'has produced an operation representing the second row from the csv' do
    expect(operation_attributes).to include(expected_attributes2)
  end

  it 'has produces operations with the correct grouping' do
    expect(operation_groups).to match_array(expected_groups)
  end

end
