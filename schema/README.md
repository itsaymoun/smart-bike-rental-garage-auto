SQL scripts for the Smart Bike Rental database (PostgreSQL 17).

## How to run
1. In pgAdmin, create a database named `smart_bike_rental`.
2. Open the Query Tool on it and run these in order, pressing F5 for each one:
   - `01_create_tables.sql`
   - `02_constraints_indexes.sql`
   - `03_seed_data.sql`
3. Refresh Schemas > public > Tables. There should be 10 tables.

## Check the data loaded
```sql
SELECT * FROM users;
SELECT * FROM wallets;
SELECT * FROM stations;
SELECT * FROM bikes;
SELECT * FROM rentals;
SELECT * FROM bike_locations;
SELECT * FROM reports;
SELECT * FROM refund_requests;
SELECT * FROM transactions;
SELECT * FROM maintenance_flags;

-- bikes per station and whether the station is full (R-04, R-15)
SELECT s.name, s.capacity, COUNT(b.bike_id) AS bikes_now,
       COUNT(b.bike_id) >= s.capacity AS is_full
FROM stations s LEFT JOIN bikes b ON b.station_id = s.station_id
GROUP BY s.station_id ORDER BY s.station_id;

-- trending stations (A-09)
SELECT s.name, COUNT(r.rental_id) AS rentals_started
FROM stations s LEFT JOIN rentals r ON r.start_station_id = s.station_id
GROUP BY s.name ORDER BY rentals_started DESC;

-- fleet status for the dashboard (A-10)
SELECT status, COUNT(*) FROM bikes GROUP BY status;
```

## Trying to break it (each line should be rejected)
| Test | Statement | Rejected by |
|------|-----------|-------------|
| Missing foreign key | `INSERT INTO rentals (user_id, bike_id, start_station_id) VALUES (999, 1, 1);` | `rentals_user_id_fkey` |
| Duplicate email | `INSERT INTO users (full_name, email, password_hash, role) VALUES ('x', 'omar.khaled@mail.com', 'h', 'admin');` | `users_email_key` |
| Same national ID twice (R-01 AC3) | `INSERT INTO users (full_name, email, password_hash, national_id) VALUES ('x', 'x@x.com', 'h', '30105150101234');` | `users_national_id_key` |
| Invalid national ID (R-01 AC2) | `INSERT INTO users (full_name, email, password_hash, national_id) VALUES ('x', 'y@x.com', 'h', '123');` | `chk_users_national_id_format` |
| Invalid bike status | `UPDATE bikes SET status = 'lost' WHERE bike_id = 1;` | `bikes_status_check` |
| Negative balance | `UPDATE wallets SET balance = -5 WHERE wallet_id = 1;` | `wallets_balance_check` |
| Bike already in use (R-06 AC2) | `INSERT INTO rentals (user_id, bike_id, start_station_id) VALUES (3, 3, 1);` | `uq_rentals_one_active_per_bike` |
| End a rental away from a dock (A-04) | `UPDATE rentals SET status = 'completed', end_time = NOW() WHERE rental_id = 6;` | `chk_rentals_end_state` |
| Damage report without a bike (R-13 AC2) | `INSERT INTO reports (user_id, report_type, description) VALUES (3, 'damage', 'x');` | `chk_reports_bike_required` |
| Empty description | `INSERT INTO reports (user_id, bike_id, report_type, description) VALUES (3, 1, 'damage', '  ');` | `reports_description_check` |
| Top-up with no payment method | `INSERT INTO transactions (wallet_id, transaction_type, amount) VALUES (1, 'top_up', 10);` | `chk_tx_top_up` |
| Delete a rider who has rentals | `DELETE FROM users WHERE user_id = 3;` | `rentals_user_id_fkey` (RESTRICT) |
| Dock a bike that is out on a rental | `UPDATE bikes SET station_id = 1 WHERE bike_id = 3;` | `chk_bikes_rented_not_docked` |
