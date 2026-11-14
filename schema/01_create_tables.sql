-- =====================================================================
-- Smart Bike Rental App - Garage Auto
-- 01_create_tables.sql
-- Run on an EMPTY database called smart_bike_rental.
-- Tables are created in dependency order (referenced tables first).
-- Every table here matches one entity in docs/erd.drawio.
-- =====================================================================


-- ---------------------------------------------------------------------
-- users  (A-01, R-01, R-02)
-- Riders and admins share one table; "role" tells them apart.
-- A rider must give a 14-digit Egyptian national ID, admins don't need one.
-- ---------------------------------------------------------------------
CREATE TABLE users (
    user_id         SERIAL PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    phone           VARCHAR(20)  UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    national_id     CHAR(14)     UNIQUE,
    is_id_verified  BOOLEAN      NOT NULL DEFAULT FALSE,
    role            VARCHAR(10)  NOT NULL DEFAULT 'rider'
                    CHECK (role IN ('rider', 'admin')),
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_users_national_id_format
        CHECK (national_id IS NULL OR national_id ~ '^[0-9]{14}$'),
    CONSTRAINT chk_users_rider_has_national_id
        CHECK (role = 'admin' OR national_id IS NOT NULL)
);


-- ---------------------------------------------------------------------
-- wallets  (R-08, R-10, A-03)
-- One wallet per rider. Balance can never go negative.
-- ---------------------------------------------------------------------
CREATE TABLE wallets (
    wallet_id   SERIAL PRIMARY KEY,
    -- CASCADE: a wallet means nothing without its owner, so if the
    -- account is deleted the wallet goes with it.
    user_id     INT NOT NULL UNIQUE
                REFERENCES users(user_id) ON DELETE CASCADE,
    balance     NUMERIC(10,2) NOT NULL DEFAULT 0
                CHECK (balance >= 0),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ---------------------------------------------------------------------
-- stations  (R-03, R-04, R-15, A-04, A-09, A-11)
-- capacity = number of docks, used to show a station as "full" (R-15).
-- The number of bikes at a station is counted from bikes.station_id,
-- so it is not stored here (keeps the table in 3NF).
-- ---------------------------------------------------------------------
CREATE TABLE stations (
    station_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    address     VARCHAR(255),
    latitude    NUMERIC(9,6) NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
    longitude   NUMERIC(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    capacity    INT NOT NULL CHECK (capacity > 0),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ---------------------------------------------------------------------
-- bikes  (R-06, A-02, A-04, A-07, A-10, A-11)
-- station_id is NULL while the bike is out on a rental.
-- ---------------------------------------------------------------------
CREATE TABLE bikes (
    bike_id     SERIAL PRIMARY KEY,
    qr_code     VARCHAR(64) NOT NULL UNIQUE,
    model       VARCHAR(50),
    status      VARCHAR(20) NOT NULL DEFAULT 'available'
                CHECK (status IN ('available', 'rented', 'maintenance', 'damaged')),
    -- SET NULL: if a station is removed, its bikes are not deleted,
    -- they just become "not docked" until moved to another station.
    station_id  INT
                REFERENCES stations(station_id) ON DELETE SET NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),

    -- a rented bike can't be sitting in a dock at the same time
    CONSTRAINT chk_bikes_rented_not_docked
        CHECK (status <> 'rented' OR station_id IS NULL)
);


-- ---------------------------------------------------------------------
-- rentals  (R-05, R-06, R-07, R-11, R-16, R-17, A-03, A-04, A-05, A-09)
-- This is the associative entity between users and bikes
-- (a rider rents many bikes over time, a bike is rented by many riders).
-- end_station_id / end_time stay NULL until the bike is locked in a dock.
-- ---------------------------------------------------------------------
CREATE TABLE rentals (
    rental_id         SERIAL PRIMARY KEY,
    -- RESTRICT: rental history is needed for payments and refunds,
    -- so a user, bike or station that has rentals can't be deleted.
    user_id           INT NOT NULL
                      REFERENCES users(user_id) ON DELETE RESTRICT,
    bike_id           INT NOT NULL
                      REFERENCES bikes(bike_id) ON DELETE RESTRICT,
    start_station_id  INT NOT NULL
                      REFERENCES stations(station_id) ON DELETE RESTRICT,
    end_station_id    INT
                      REFERENCES stations(station_id) ON DELETE RESTRICT,
    start_time        TIMESTAMP NOT NULL DEFAULT NOW(),
    end_time          TIMESTAMP,
    status            VARCHAR(10) NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active', 'completed')),
    distance_km       NUMERIC(6,2) CHECK (distance_km    >= 0),
    calories_burnt    INT          CHECK (calories_burnt >= 0),
    co2_saved_g       NUMERIC(8,2) CHECK (co2_saved_g    >= 0),

    -- A-04 / A-05: a rental only ends when the bike is docked at a station
    CONSTRAINT chk_rentals_end_state CHECK (
        (status = 'active'    AND end_time IS NULL     AND end_station_id IS NULL) OR
        (status = 'completed' AND end_time IS NOT NULL AND end_station_id IS NOT NULL)
    ),
    CONSTRAINT chk_rentals_time_order
        CHECK (end_time IS NULL OR end_time > start_time)
);


-- ---------------------------------------------------------------------
-- bike_locations  (A-02, R-17)
-- GPS points sent by each bike's tracker. A trip's route is the points
-- of that bike between the rental's start_time and end_time.
-- ---------------------------------------------------------------------
CREATE TABLE bike_locations (
    bike_location_id  BIGSERIAL PRIMARY KEY,
    -- CASCADE: tracking points are only useful together with their bike.
    bike_id           INT NOT NULL
                      REFERENCES bikes(bike_id) ON DELETE CASCADE,
    latitude          NUMERIC(9,6) NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
    longitude         NUMERIC(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    recorded_at       TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ---------------------------------------------------------------------
-- reports  (R-13, R-14, A-06, A-07)
-- damage / problem reports must name a bike (R-13 AC2).
-- special_case reports are about a rental and may lead to a refund.
-- ---------------------------------------------------------------------
CREATE TABLE reports (
    report_id        SERIAL PRIMARY KEY,
    -- RESTRICT: reports are case records, we don't lose them silently.
    user_id          INT NOT NULL
                     REFERENCES users(user_id) ON DELETE RESTRICT,
    bike_id          INT
                     REFERENCES bikes(bike_id) ON DELETE RESTRICT,
    rental_id        INT
                     REFERENCES rentals(rental_id) ON DELETE RESTRICT,
    report_type      VARCHAR(15) NOT NULL
                     CHECK (report_type IN ('damage', 'problem', 'special_case')),
    description      TEXT NOT NULL CHECK (LENGTH(TRIM(description)) > 0),
    proof_url        VARCHAR(500),
    status           VARCHAR(10) NOT NULL DEFAULT 'open'
                     CHECK (status IN ('open', 'resolved')),
    resolution_note  TEXT,
    -- SET NULL: if the admin account is removed the report keeps its
    -- outcome, we just lose who resolved it.
    resolved_by      INT
                     REFERENCES users(user_id) ON DELETE SET NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at      TIMESTAMP,

    CONSTRAINT chk_reports_bike_required
        CHECK (report_type = 'special_case' OR bike_id IS NOT NULL),
    CONSTRAINT chk_reports_rental_required
        CHECK (report_type <> 'special_case' OR rental_id IS NOT NULL),
    CONSTRAINT chk_reports_resolved_state
        CHECK (status = 'open' OR resolved_at IS NOT NULL)
);


-- ---------------------------------------------------------------------
-- refund_requests  (R-14, A-06)
-- Created from a special-case report. One report -> at most one request.
-- ---------------------------------------------------------------------
CREATE TABLE refund_requests (
    refund_request_id  SERIAL PRIMARY KEY,
    -- CASCADE: the request is part of the report, it can't exist alone.
    report_id          INT NOT NULL UNIQUE
                       REFERENCES reports(report_id) ON DELETE CASCADE,
    amount             NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    status             VARCHAR(10) NOT NULL DEFAULT 'pending'
                       CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_note         TEXT,
    -- SET NULL: same reason as reports.resolved_by
    reviewed_by        INT
                       REFERENCES users(user_id) ON DELETE SET NULL,
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
    reviewed_at        TIMESTAMP,

    CONSTRAINT chk_refund_reviewed_state
        CHECK (status = 'pending' OR reviewed_at IS NOT NULL)
);


-- ---------------------------------------------------------------------
-- transactions  (R-07, R-10, R-12, A-03, A-06)
--  top_up : money in from Visa / Mastercard / InstaPay / Vodafone Cash
--  charge : money out for a finished rental (linked to rental_id)
--  refund : money back after an approved refund request
-- balance_after is kept so the receipt can show the remaining balance
-- at that moment (R-07 AC1).
-- ---------------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id     SERIAL PRIMARY KEY,
    -- RESTRICT: financial records must never disappear with a wallet.
    wallet_id          INT NOT NULL
                       REFERENCES wallets(wallet_id) ON DELETE RESTRICT,
    rental_id          INT
                       REFERENCES rentals(rental_id) ON DELETE RESTRICT,
    refund_request_id  INT UNIQUE
                       REFERENCES refund_requests(refund_request_id) ON DELETE RESTRICT,
    transaction_type   VARCHAR(10) NOT NULL
                       CHECK (transaction_type IN ('top_up', 'charge', 'refund')),
    amount             NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method     VARCHAR(20)
                       CHECK (payment_method IN ('visa', 'mastercard', 'instapay', 'vodafone_cash')),
    status             VARCHAR(10) NOT NULL DEFAULT 'success'
                       CHECK (status IN ('pending', 'success', 'failed', 'cancelled')),
    balance_after      NUMERIC(10,2) CHECK (balance_after >= 0),
    created_at         TIMESTAMP NOT NULL DEFAULT NOW(),

    -- each type must point at the right thing
    CONSTRAINT chk_tx_top_up CHECK (
        transaction_type <> 'top_up'
        OR (payment_method IS NOT NULL AND rental_id IS NULL AND refund_request_id IS NULL)
    ),
    CONSTRAINT chk_tx_charge CHECK (
        transaction_type <> 'charge'
        OR (rental_id IS NOT NULL AND payment_method IS NULL AND refund_request_id IS NULL)
    ),
    CONSTRAINT chk_tx_refund CHECK (
        transaction_type <> 'refund'
        OR (refund_request_id IS NOT NULL AND payment_method IS NULL AND rental_id IS NULL)
    )
);


-- ---------------------------------------------------------------------
-- maintenance_flags  (A-07, A-08, A-10)
-- An admin flags a bike with a reason; the flag is closed after repair.
-- ---------------------------------------------------------------------
CREATE TABLE maintenance_flags (
    maintenance_flag_id  SERIAL PRIMARY KEY,
    -- RESTRICT: keep the repair history of every bike.
    bike_id              INT NOT NULL
                         REFERENCES bikes(bike_id) ON DELETE RESTRICT,
    -- RESTRICT: we always want to know which admin flagged the bike.
    flagged_by           INT NOT NULL
                         REFERENCES users(user_id) ON DELETE RESTRICT,
    reason               TEXT NOT NULL CHECK (LENGTH(TRIM(reason)) > 0),
    status               VARCHAR(10) NOT NULL DEFAULT 'open'
                         CHECK (status IN ('open', 'resolved')),
    flagged_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at          TIMESTAMP,

    CONSTRAINT chk_flags_resolved_state
        CHECK (status = 'open' OR resolved_at IS NOT NULL),
    CONSTRAINT chk_flags_time_order
        CHECK (resolved_at IS NULL OR resolved_at >= flagged_at)
);
