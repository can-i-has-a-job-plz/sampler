# frozen_string_literal: true

class CreateSamplerSamples < ActiveRecord::Migration[5.0] # :nodoc:
  def change
    create_table :sampler_samples do |t|
      t.string :endpoint, null: false, index: true
      t.string :url, null: false
      t.string :request_method, null: false, index: true
      t.jsonb :params, null: false
      t.text :request_body, null: false
      t.text :response_body, null: false
      t.string :tags, array: true, null: false

      t.timestamps
    end
  end
end
