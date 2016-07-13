require 'spec_helper'

describe AbPanel::Javascript do
  it 'returns json of all relevant properties, funnels and experiments' do
    AbPanel.set_env('distinct_id', 'distinct_id')
    AbPanel.set_env(:properties, { post_name: 'test' })
    result = JSON.parse(AbPanel::Javascript.environment)
    expect(result['distinct_id']).to eq 'distinct_id'
  end

  it 'works without extra properties' do
    AbPanel.set_env(:properties, nil)
    result = JSON.parse(AbPanel::Javascript.environment)
    expect(result['distinct_id']).to eq 'distinct_id'
  end
end
