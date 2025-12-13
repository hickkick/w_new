Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :uuid, null: false, uniqe: true

      String :nickname
      String :email
      String :telegram_id

      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
