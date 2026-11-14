-- =====================================================================
-- Smart Bike Rental App - Garage Auto
-- 03_seed_data.sql
-- Sample rows to prove the relationships work. Run after 01 and 02.
--
-- Pricing we assumed for the sample data (rough numbers, not final):
--   unlock fee       = 5 EGP
--   per minute       = 1 EGP
--   minimum balance  = 30 EGP to start a rental (A-03)
--   calories         ~ 30 kcal per km
--   CO2 saved        ~ 120 g per km (what a normal car would emit)
--
-- IDs are not written by hand, they come from SERIAL in insert order.
-- The comments show which id each row gets.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- users: 1-2 admins, 3-7 riders
-- (password_hash values are fake placeholders, not real hashes)
-- ---------------------------------------------------------------------
INSERT INTO users (full_name, email, phone, password_hash, national_id, is_id_verified, role) VALUES
('Karim Adel',      'karim.admin@smartbike.eg', '01000000001', 'hash_admin_1', NULL,             FALSE, 'admin'),  -- 1
('Nour Hassan',     'nour.admin@smartbike.eg',  '01000000002', 'hash_admin_2', NULL,             FALSE, 'admin'),  -- 2
('Omar Khaled',     'omar.khaled@mail.com',     '01111111111', 'hash_rider_3', '30105150101234', TRUE,  'rider'),  -- 3
('Salma Mostafa',   'salma.m@mail.com',         '01222222222', 'hash_rider_4', '30208210102345', TRUE,  'rider'),  -- 4
('Youssef Tarek',   'youssef.t@mail.com',       '01033333333', 'hash_rider_5', '30011030103456', TRUE,  'rider'),  -- 5
('Mariam Ashraf',   'mariam.a@mail.com',        '01544444444', 'hash_rider_6', '30303120104567', TRUE,  'rider'),  -- 6
('Ali Samy',        'ali.samy@mail.com',        '01155555555', 'hash_rider_7', '30409250105678', TRUE,  'rider');  -- 7

-- ---------------------------------------------------------------------
-- wallets: one per rider. Final balances match the transactions below.
-- ---------------------------------------------------------------------
INSERT INTO wallets (user_id, balance) VALUES
(3,  50.00),   -- wallet 1  (Omar)
(4, 120.00),   -- wallet 2  (Salma)
(5,  23.00),   -- wallet 3  (Youssef) below 30 EGP -> can't start a rental (A-03)
(6, 165.00),   -- wallet 4  (Mariam)
(7,   0.00);   -- wallet 5  (Ali) new rider, no transactions yet (R-12 AC2)

-- ---------------------------------------------------------------------
-- stations around GIU, New Administrative Capital
-- ---------------------------------------------------------------------
INSERT INTO stations (name, address, latitude, longitude, capacity) VALUES
('GIU Main Gate',        'GIU campus, main entrance',        30.018400, 31.739100, 10),  -- 1
('GIU Student Housing',  'GIU dorms entrance',               30.021300, 31.742600,  8),  -- 2
('Capital Park',         'Central park, south gate',         30.012700, 31.751800,  6),  -- 3
('R5 Plaza',             'R5 residential district',          30.025900, 31.733400,  2),  -- 4 full (R-15)
('R7 District',          'R7 residential district',          30.006800, 31.729500,  6);  -- 5 empty (R-04 AC2)

-- ---------------------------------------------------------------------
-- bikes
-- ---------------------------------------------------------------------
INSERT INTO bikes (qr_code, model, status, station_id) VALUES
('QR-BK-0001', 'City Classic', 'available',   2),     -- 1
('QR-BK-0002', 'City Classic', 'available',   1),     -- 2
('QR-BK-0003', 'Urban Sport',  'rented',      NULL),  -- 3 out on rental 6
('QR-BK-0004', 'Urban Sport',  'available',   1),     -- 4
('QR-BK-0005', 'City Classic', 'available',   3),     -- 5
('QR-BK-0006', 'Urban Sport',  'available',   2),     -- 6
('QR-BK-0007', 'City Classic', 'damaged',     3),     -- 7 reported damaged (A-07)
('QR-BK-0008', 'Urban Sport',  'maintenance', 4),     -- 8 flagged (A-08)
('QR-BK-0009', 'City Classic', 'available',   4);     -- 9

-- ---------------------------------------------------------------------
-- rentals  (cost = 5 + minutes, see transactions)
-- ---------------------------------------------------------------------
INSERT INTO rentals (user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES
(3, 1, 1, 2,    '2026-11-01 09:00', '2026-11-01 09:18', 'completed', 3.20,  96, 384.00),  -- 1: 18 min -> 23 EGP
(4, 2, 2, 1,    '2026-11-02 14:10', '2026-11-02 14:35', 'completed', 4.50, 135, 540.00),  -- 2: 25 min -> 30 EGP
(5, 5, 1, 3,    '2026-11-03 08:00', '2026-11-03 08:12', 'completed', 2.10,  63, 252.00),  -- 3: 12 min -> 17 EGP
(3, 4, 3, 1,    '2026-11-05 17:30', '2026-11-05 17:52', 'completed', 3.80, 114, 456.00),  -- 4: 22 min -> 27 EGP
(6, 6, 2, 2,    '2026-11-06 10:00', '2026-11-06 13:00', 'completed', 1.40,  42, 168.00),  -- 5: 180 min -> 185 EGP (lock problem, refunded)
(4, 3, 1, NULL, '2026-11-14 18:30', NULL,               'active',    NULL, NULL,   NULL); -- 6: still riding (R-05 AC2)

-- ---------------------------------------------------------------------
-- bike_locations: tracker points (A-02, R-17)
-- ---------------------------------------------------------------------
INSERT INTO bike_locations (bike_id, latitude, longitude, recorded_at) VALUES
-- route of rental 1 (bike 1)
(1, 30.018400, 31.739100, '2026-11-01 09:00'),
(1, 30.019500, 31.740300, '2026-11-01 09:06'),
(1, 30.020600, 31.741500, '2026-11-01 09:12'),
(1, 30.021300, 31.742600, '2026-11-01 09:18'),
-- active rental 6 (bike 3), updates every few minutes
(3, 30.018400, 31.739100, '2026-11-14 18:30'),
(3, 30.016900, 31.742000, '2026-11-14 18:35'),
(3, 30.015200, 31.745300, '2026-11-14 18:40'),
-- docked bikes report their position too
(2, 30.018400, 31.739100, '2026-11-14 18:00'),
(5, 30.012700, 31.751800, '2026-11-14 18:00'),
(9, 30.025900, 31.733400, '2026-11-14 18:00');

-- ---------------------------------------------------------------------
-- reports
-- ---------------------------------------------------------------------
INSERT INTO reports (user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES
(3, 7,    NULL, 'damage',       'Front brake is not working at all.',                                   NULL,                                   'open',     NULL,                                           NULL, '2026-11-08 12:00', NULL),               -- 1
(4, 2,    2,    'problem',      'Seat kept sliding down during the ride.',                              NULL,                                   'resolved', 'Seat clamp tightened.',                        1,    '2026-11-02 14:40', '2026-11-03 10:00'), -- 2
(6, NULL, 5,    'special_case', 'I docked at 10:40 but the lock did not click, I was charged 3 hours.', 'https://files.smartbike.eg/proof/5.jpg', 'resolved', 'Station log confirms docking at 10:40.',       2,    '2026-11-06 13:10', '2026-11-07 11:00'), -- 3
(5, 8,    NULL, 'damage',       'Chain keeps slipping when going uphill.',                              NULL,                                   'resolved', 'Bike sent to maintenance.',                    1,    '2026-11-09 09:30', '2026-11-09 15:00'), -- 4
(3, NULL, 4,    'special_case', 'App froze at the end, I think I paid a few extra minutes.',            NULL,                                   'open',     NULL,                                           NULL, '2026-11-05 18:05', NULL),               -- 5
(5, NULL, 3,    'special_case', 'I want a refund because the ride was short.',                          NULL,                                   'resolved', 'Normal ride, no system issue.',                2,    '2026-11-03 09:00', '2026-11-04 12:00'); -- 6

-- ---------------------------------------------------------------------
-- refund_requests (A-06: approved / pending / rejected)
-- ---------------------------------------------------------------------
INSERT INTO refund_requests (report_id, amount, status, admin_note, reviewed_by, created_at, reviewed_at) VALUES
(3, 150.00, 'approved', 'Refunding the 150 minutes after real docking time.', 2,    '2026-11-06 13:10', '2026-11-07 11:00'),  -- 1
(5,   5.00, 'pending',  NULL,                                                 NULL, '2026-11-05 18:05', NULL),                -- 2
(6,  17.00, 'rejected', 'Ride was charged correctly.',                        2,    '2026-11-03 09:00', '2026-11-04 12:00');  -- 3

-- ---------------------------------------------------------------------
-- transactions (balance_after follows each wallet step by step)
-- ---------------------------------------------------------------------
INSERT INTO transactions (wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES
-- wallet 1 (Omar): 0 -> 100 -> 77 -> 50
(1, NULL, NULL, 'top_up', 100.00, 'visa',          'success', 100.00, '2026-10-31 20:00'),
(1, 1,    NULL, 'charge',  23.00, NULL,            'success',  77.00, '2026-11-01 09:18'),
(1, 4,    NULL, 'charge',  27.00, NULL,            'success',  50.00, '2026-11-05 17:52'),
-- wallet 2 (Salma): 0 -> 50 -> 20 -> 120, one failed top-up (R-10 AC2)
(2, NULL, NULL, 'top_up',  50.00, 'instapay',      'success',  50.00, '2026-11-02 13:50'),
(2, 2,    NULL, 'charge',  30.00, NULL,            'success',  20.00, '2026-11-02 14:35'),
(2, NULL, NULL, 'top_up', 200.00, 'mastercard',    'failed',   20.00, '2026-11-14 18:10'),
(2, NULL, NULL, 'top_up', 100.00, 'vodafone_cash', 'success', 120.00, '2026-11-14 18:15'),
-- wallet 3 (Youssef): 0 -> 40 -> 23
(3, NULL, NULL, 'top_up',  40.00, 'vodafone_cash', 'success',  40.00, '2026-11-02 22:00'),
(3, 3,    NULL, 'charge',  17.00, NULL,            'success',  23.00, '2026-11-03 08:12'),
-- wallet 4 (Mariam): 0 -> 200 -> 15 -> 165 (refund)
(4, NULL, NULL, 'top_up', 200.00, 'visa',          'success', 200.00, '2026-11-06 09:45'),
(4, 5,    NULL, 'charge', 185.00, NULL,            'success',  15.00, '2026-11-06 13:00'),
(4, NULL, 1,    'refund', 150.00, NULL,            'success', 165.00, '2026-11-07 11:00');

-- ---------------------------------------------------------------------
-- maintenance_flags (A-08)
-- ---------------------------------------------------------------------
INSERT INTO maintenance_flags (bike_id, flagged_by, reason, status, flagged_at, resolved_at) VALUES
(8, 1, 'Chain slipping (from report #4).', 'open',     '2026-11-09 15:00', NULL),
(2, 1, 'Loose seat clamp.',                'resolved', '2026-11-02 16:00', '2026-11-03 10:00');

COMMIT;
