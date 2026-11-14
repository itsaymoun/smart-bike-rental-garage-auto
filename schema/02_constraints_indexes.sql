-- =====================================================================
-- Smart Bike Rental App - Garage Auto
-- 02_constraints_indexes.sql
-- Extra rules that can't be written inside CREATE TABLE, plus indexes
-- for the queries the backlog needs. Run after 01_create_tables.sql.
-- =====================================================================

-- R-06 AC2: a bike that is already in use can't be rented again.
-- Only one ACTIVE rental per bike at a time.
CREATE UNIQUE INDEX uq_rentals_one_active_per_bike
    ON rentals (bike_id)
    WHERE status = 'active';

-- A rider can only ride one bike at a time.
CREATE UNIQUE INDEX uq_rentals_one_active_per_user
    ON rentals (user_id)
    WHERE status = 'active';

-- A bike shouldn't have two open maintenance flags at the same time (A-08).
CREATE UNIQUE INDEX uq_flags_one_open_per_bike
    ON maintenance_flags (bike_id)
    WHERE status = 'open';

-- R-04 / R-15: count bikes at each station quickly
CREATE INDEX idx_bikes_station ON bikes (station_id);

-- A-07 / A-10 / A-11: dashboard filters bikes by status
CREATE INDEX idx_bikes_status ON bikes (status);

-- A-02 / R-17: latest position of a bike, and a trip's route
CREATE INDEX idx_bike_locations_bike_time ON bike_locations (bike_id, recorded_at);

-- A-09: trending stations = number of rentals starting at each station
CREATE INDEX idx_rentals_start_station ON rentals (start_station_id);

-- R-12: a rider's transaction history, newest first
CREATE INDEX idx_transactions_wallet_time ON transactions (wallet_id, created_at DESC);

-- A-06 / A-07: admin opens the list of open reports
CREATE INDEX idx_reports_status ON reports (status, created_at);
