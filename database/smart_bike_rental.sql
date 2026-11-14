--
-- PostgreSQL database dump
--


-- Dumped from database version 17.11 (Debian 17.11-1.pgdg13+2)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.wallets DROP CONSTRAINT IF EXISTS wallets_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_wallet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_rental_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_refund_request_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reports DROP CONSTRAINT IF EXISTS reports_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reports DROP CONSTRAINT IF EXISTS reports_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.reports DROP CONSTRAINT IF EXISTS reports_rental_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reports DROP CONSTRAINT IF EXISTS reports_bike_id_fkey;
ALTER TABLE IF EXISTS ONLY public.rentals DROP CONSTRAINT IF EXISTS rentals_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.rentals DROP CONSTRAINT IF EXISTS rentals_start_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.rentals DROP CONSTRAINT IF EXISTS rentals_end_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.rentals DROP CONSTRAINT IF EXISTS rentals_bike_id_fkey;
ALTER TABLE IF EXISTS ONLY public.refund_requests DROP CONSTRAINT IF EXISTS refund_requests_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.refund_requests DROP CONSTRAINT IF EXISTS refund_requests_report_id_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_flags DROP CONSTRAINT IF EXISTS maintenance_flags_flagged_by_fkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_flags DROP CONSTRAINT IF EXISTS maintenance_flags_bike_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bikes DROP CONSTRAINT IF EXISTS bikes_station_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bike_locations DROP CONSTRAINT IF EXISTS bike_locations_bike_id_fkey;
DROP INDEX IF EXISTS public.uq_rentals_one_active_per_user;
DROP INDEX IF EXISTS public.uq_rentals_one_active_per_bike;
DROP INDEX IF EXISTS public.uq_flags_one_open_per_bike;
DROP INDEX IF EXISTS public.idx_transactions_wallet_time;
DROP INDEX IF EXISTS public.idx_reports_status;
DROP INDEX IF EXISTS public.idx_rentals_start_station;
DROP INDEX IF EXISTS public.idx_bikes_status;
DROP INDEX IF EXISTS public.idx_bikes_station;
DROP INDEX IF EXISTS public.idx_bike_locations_bike_time;
ALTER TABLE IF EXISTS ONLY public.wallets DROP CONSTRAINT IF EXISTS wallets_user_id_key;
ALTER TABLE IF EXISTS ONLY public.wallets DROP CONSTRAINT IF EXISTS wallets_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_national_id_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_refund_request_id_key;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.stations DROP CONSTRAINT IF EXISTS stations_pkey;
ALTER TABLE IF EXISTS ONLY public.stations DROP CONSTRAINT IF EXISTS stations_name_key;
ALTER TABLE IF EXISTS ONLY public.reports DROP CONSTRAINT IF EXISTS reports_pkey;
ALTER TABLE IF EXISTS ONLY public.rentals DROP CONSTRAINT IF EXISTS rentals_pkey;
ALTER TABLE IF EXISTS ONLY public.refund_requests DROP CONSTRAINT IF EXISTS refund_requests_report_id_key;
ALTER TABLE IF EXISTS ONLY public.refund_requests DROP CONSTRAINT IF EXISTS refund_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.maintenance_flags DROP CONSTRAINT IF EXISTS maintenance_flags_pkey;
ALTER TABLE IF EXISTS ONLY public.bikes DROP CONSTRAINT IF EXISTS bikes_qr_code_key;
ALTER TABLE IF EXISTS ONLY public.bikes DROP CONSTRAINT IF EXISTS bikes_pkey;
ALTER TABLE IF EXISTS ONLY public.bike_locations DROP CONSTRAINT IF EXISTS bike_locations_pkey;
ALTER TABLE IF EXISTS public.wallets ALTER COLUMN wallet_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.users ALTER COLUMN user_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.transactions ALTER COLUMN transaction_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.stations ALTER COLUMN station_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reports ALTER COLUMN report_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.rentals ALTER COLUMN rental_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.refund_requests ALTER COLUMN refund_request_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.maintenance_flags ALTER COLUMN maintenance_flag_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bikes ALTER COLUMN bike_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bike_locations ALTER COLUMN bike_location_id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.wallets_wallet_id_seq;
DROP TABLE IF EXISTS public.wallets;
DROP SEQUENCE IF EXISTS public.users_user_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.transactions_transaction_id_seq;
DROP TABLE IF EXISTS public.transactions;
DROP SEQUENCE IF EXISTS public.stations_station_id_seq;
DROP TABLE IF EXISTS public.stations;
DROP SEQUENCE IF EXISTS public.reports_report_id_seq;
DROP TABLE IF EXISTS public.reports;
DROP SEQUENCE IF EXISTS public.rentals_rental_id_seq;
DROP TABLE IF EXISTS public.rentals;
DROP SEQUENCE IF EXISTS public.refund_requests_refund_request_id_seq;
DROP TABLE IF EXISTS public.refund_requests;
DROP SEQUENCE IF EXISTS public.maintenance_flags_maintenance_flag_id_seq;
DROP TABLE IF EXISTS public.maintenance_flags;
DROP SEQUENCE IF EXISTS public.bikes_bike_id_seq;
DROP TABLE IF EXISTS public.bikes;
DROP SEQUENCE IF EXISTS public.bike_locations_bike_location_id_seq;
DROP TABLE IF EXISTS public.bike_locations;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bike_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bike_locations (
    bike_location_id bigint NOT NULL,
    bike_id integer NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    recorded_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT bike_locations_latitude_check CHECK (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT bike_locations_longitude_check CHECK (((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric)))
);


--
-- Name: bike_locations_bike_location_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bike_locations_bike_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bike_locations_bike_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bike_locations_bike_location_id_seq OWNED BY public.bike_locations.bike_location_id;


--
-- Name: bikes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bikes (
    bike_id integer NOT NULL,
    qr_code character varying(64) NOT NULL,
    model character varying(50),
    status character varying(20) DEFAULT 'available'::character varying NOT NULL,
    station_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT bikes_status_check CHECK (((status)::text = ANY ((ARRAY['available'::character varying, 'rented'::character varying, 'maintenance'::character varying, 'damaged'::character varying])::text[]))),
    CONSTRAINT chk_bikes_rented_not_docked CHECK ((((status)::text <> 'rented'::text) OR (station_id IS NULL)))
);


--
-- Name: bikes_bike_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bikes_bike_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bikes_bike_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bikes_bike_id_seq OWNED BY public.bikes.bike_id;


--
-- Name: maintenance_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maintenance_flags (
    maintenance_flag_id integer NOT NULL,
    bike_id integer NOT NULL,
    flagged_by integer NOT NULL,
    reason text NOT NULL,
    status character varying(10) DEFAULT 'open'::character varying NOT NULL,
    flagged_at timestamp without time zone DEFAULT now() NOT NULL,
    resolved_at timestamp without time zone,
    CONSTRAINT chk_flags_resolved_state CHECK ((((status)::text = 'open'::text) OR (resolved_at IS NOT NULL))),
    CONSTRAINT chk_flags_time_order CHECK (((resolved_at IS NULL) OR (resolved_at >= flagged_at))),
    CONSTRAINT maintenance_flags_reason_check CHECK ((length(TRIM(BOTH FROM reason)) > 0)),
    CONSTRAINT maintenance_flags_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'resolved'::character varying])::text[])))
);


--
-- Name: maintenance_flags_maintenance_flag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maintenance_flags_maintenance_flag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maintenance_flags_maintenance_flag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maintenance_flags_maintenance_flag_id_seq OWNED BY public.maintenance_flags.maintenance_flag_id;


--
-- Name: refund_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund_requests (
    refund_request_id integer NOT NULL,
    report_id integer NOT NULL,
    amount numeric(10,2) NOT NULL,
    status character varying(10) DEFAULT 'pending'::character varying NOT NULL,
    admin_note text,
    reviewed_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    reviewed_at timestamp without time zone,
    CONSTRAINT chk_refund_reviewed_state CHECK ((((status)::text = 'pending'::text) OR (reviewed_at IS NOT NULL))),
    CONSTRAINT refund_requests_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT refund_requests_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[])))
);


--
-- Name: refund_requests_refund_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refund_requests_refund_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refund_requests_refund_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refund_requests_refund_request_id_seq OWNED BY public.refund_requests.refund_request_id;


--
-- Name: rentals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rentals (
    rental_id integer NOT NULL,
    user_id integer NOT NULL,
    bike_id integer NOT NULL,
    start_station_id integer NOT NULL,
    end_station_id integer,
    start_time timestamp without time zone DEFAULT now() NOT NULL,
    end_time timestamp without time zone,
    status character varying(10) DEFAULT 'active'::character varying NOT NULL,
    distance_km numeric(6,2),
    calories_burnt integer,
    co2_saved_g numeric(8,2),
    CONSTRAINT chk_rentals_end_state CHECK (((((status)::text = 'active'::text) AND (end_time IS NULL) AND (end_station_id IS NULL)) OR (((status)::text = 'completed'::text) AND (end_time IS NOT NULL) AND (end_station_id IS NOT NULL)))),
    CONSTRAINT chk_rentals_time_order CHECK (((end_time IS NULL) OR (end_time > start_time))),
    CONSTRAINT rentals_calories_burnt_check CHECK ((calories_burnt >= 0)),
    CONSTRAINT rentals_co2_saved_g_check CHECK ((co2_saved_g >= (0)::numeric)),
    CONSTRAINT rentals_distance_km_check CHECK ((distance_km >= (0)::numeric)),
    CONSTRAINT rentals_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'completed'::character varying])::text[])))
);


--
-- Name: rentals_rental_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rentals_rental_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rentals_rental_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rentals_rental_id_seq OWNED BY public.rentals.rental_id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    report_id integer NOT NULL,
    user_id integer NOT NULL,
    bike_id integer,
    rental_id integer,
    report_type character varying(15) NOT NULL,
    description text NOT NULL,
    proof_url character varying(500),
    status character varying(10) DEFAULT 'open'::character varying NOT NULL,
    resolution_note text,
    resolved_by integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    resolved_at timestamp without time zone,
    CONSTRAINT chk_reports_bike_required CHECK ((((report_type)::text = 'special_case'::text) OR (bike_id IS NOT NULL))),
    CONSTRAINT chk_reports_rental_required CHECK ((((report_type)::text <> 'special_case'::text) OR (rental_id IS NOT NULL))),
    CONSTRAINT chk_reports_resolved_state CHECK ((((status)::text = 'open'::text) OR (resolved_at IS NOT NULL))),
    CONSTRAINT reports_description_check CHECK ((length(TRIM(BOTH FROM description)) > 0)),
    CONSTRAINT reports_report_type_check CHECK (((report_type)::text = ANY ((ARRAY['damage'::character varying, 'problem'::character varying, 'special_case'::character varying])::text[]))),
    CONSTRAINT reports_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'resolved'::character varying])::text[])))
);


--
-- Name: reports_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reports_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reports_report_id_seq OWNED BY public.reports.report_id;


--
-- Name: stations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stations (
    station_id integer NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(255),
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    capacity integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT stations_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT stations_latitude_check CHECK (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric))),
    CONSTRAINT stations_longitude_check CHECK (((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric)))
);


--
-- Name: stations_station_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stations_station_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stations_station_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stations_station_id_seq OWNED BY public.stations.station_id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    transaction_id integer NOT NULL,
    wallet_id integer NOT NULL,
    rental_id integer,
    refund_request_id integer,
    transaction_type character varying(10) NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(20),
    status character varying(10) DEFAULT 'success'::character varying NOT NULL,
    balance_after numeric(10,2),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_tx_charge CHECK ((((transaction_type)::text <> 'charge'::text) OR ((rental_id IS NOT NULL) AND (payment_method IS NULL) AND (refund_request_id IS NULL)))),
    CONSTRAINT chk_tx_refund CHECK ((((transaction_type)::text <> 'refund'::text) OR ((refund_request_id IS NOT NULL) AND (payment_method IS NULL) AND (rental_id IS NULL)))),
    CONSTRAINT chk_tx_top_up CHECK ((((transaction_type)::text <> 'top_up'::text) OR ((payment_method IS NOT NULL) AND (rental_id IS NULL) AND (refund_request_id IS NULL)))),
    CONSTRAINT transactions_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT transactions_balance_after_check CHECK ((balance_after >= (0)::numeric)),
    CONSTRAINT transactions_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['visa'::character varying, 'mastercard'::character varying, 'instapay'::character varying, 'vodafone_cash'::character varying])::text[]))),
    CONSTRAINT transactions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'success'::character varying, 'failed'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT transactions_transaction_type_check CHECK (((transaction_type)::text = ANY ((ARRAY['top_up'::character varying, 'charge'::character varying, 'refund'::character varying])::text[])))
);


--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_transaction_id_seq OWNED BY public.transactions.transaction_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(20),
    password_hash character varying(255) NOT NULL,
    national_id character(14),
    is_id_verified boolean DEFAULT false NOT NULL,
    role character varying(10) DEFAULT 'rider'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_users_national_id_format CHECK (((national_id IS NULL) OR (national_id ~ '^[0-9]{14}$'::text))),
    CONSTRAINT chk_users_rider_has_national_id CHECK ((((role)::text = 'admin'::text) OR (national_id IS NOT NULL))),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['rider'::character varying, 'admin'::character varying])::text[])))
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: wallets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallets (
    wallet_id integer NOT NULL,
    user_id integer NOT NULL,
    balance numeric(10,2) DEFAULT 0 NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallets_balance_check CHECK ((balance >= (0)::numeric))
);


--
-- Name: wallets_wallet_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wallets_wallet_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallets_wallet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wallets_wallet_id_seq OWNED BY public.wallets.wallet_id;


--
-- Name: bike_locations bike_location_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bike_locations ALTER COLUMN bike_location_id SET DEFAULT nextval('public.bike_locations_bike_location_id_seq'::regclass);


--
-- Name: bikes bike_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bikes ALTER COLUMN bike_id SET DEFAULT nextval('public.bikes_bike_id_seq'::regclass);


--
-- Name: maintenance_flags maintenance_flag_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_flags ALTER COLUMN maintenance_flag_id SET DEFAULT nextval('public.maintenance_flags_maintenance_flag_id_seq'::regclass);


--
-- Name: refund_requests refund_request_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests ALTER COLUMN refund_request_id SET DEFAULT nextval('public.refund_requests_refund_request_id_seq'::regclass);


--
-- Name: rentals rental_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rentals ALTER COLUMN rental_id SET DEFAULT nextval('public.rentals_rental_id_seq'::regclass);


--
-- Name: reports report_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports ALTER COLUMN report_id SET DEFAULT nextval('public.reports_report_id_seq'::regclass);


--
-- Name: stations station_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stations ALTER COLUMN station_id SET DEFAULT nextval('public.stations_station_id_seq'::regclass);


--
-- Name: transactions transaction_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions ALTER COLUMN transaction_id SET DEFAULT nextval('public.transactions_transaction_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: wallets wallet_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets ALTER COLUMN wallet_id SET DEFAULT nextval('public.wallets_wallet_id_seq'::regclass);


--
-- Data for Name: bike_locations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (1, 1, 30.018400, 31.739100, '2026-11-01 09:00:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (2, 1, 30.019500, 31.740300, '2026-11-01 09:06:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (3, 1, 30.020600, 31.741500, '2026-11-01 09:12:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (4, 1, 30.021300, 31.742600, '2026-11-01 09:18:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (5, 3, 30.018400, 31.739100, '2026-11-14 18:30:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (6, 3, 30.016900, 31.742000, '2026-11-14 18:35:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (7, 3, 30.015200, 31.745300, '2026-11-14 18:40:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (8, 2, 30.018400, 31.739100, '2026-11-14 18:00:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (9, 5, 30.012700, 31.751800, '2026-11-14 18:00:00');
INSERT INTO public.bike_locations (bike_location_id, bike_id, latitude, longitude, recorded_at) VALUES (10, 9, 30.025900, 31.733400, '2026-11-14 18:00:00');


--
-- Data for Name: bikes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (1, 'QR-BK-0001', 'City Classic', 'available', 2, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (2, 'QR-BK-0002', 'City Classic', 'available', 1, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (3, 'QR-BK-0003', 'Urban Sport', 'rented', NULL, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (4, 'QR-BK-0004', 'Urban Sport', 'available', 1, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (5, 'QR-BK-0005', 'City Classic', 'available', 3, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (6, 'QR-BK-0006', 'Urban Sport', 'available', 2, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (7, 'QR-BK-0007', 'City Classic', 'damaged', 3, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (8, 'QR-BK-0008', 'Urban Sport', 'maintenance', 4, '2026-11-14 22:00:52.189959');
INSERT INTO public.bikes (bike_id, qr_code, model, status, station_id, created_at) VALUES (9, 'QR-BK-0009', 'City Classic', 'available', 4, '2026-11-14 22:00:52.189959');


--
-- Data for Name: maintenance_flags; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.maintenance_flags (maintenance_flag_id, bike_id, flagged_by, reason, status, flagged_at, resolved_at) VALUES (1, 8, 1, 'Chain slipping (from report #4).', 'open', '2026-11-09 15:00:00', NULL);
INSERT INTO public.maintenance_flags (maintenance_flag_id, bike_id, flagged_by, reason, status, flagged_at, resolved_at) VALUES (2, 2, 1, 'Loose seat clamp.', 'resolved', '2026-11-02 16:00:00', '2026-11-03 10:00:00');


--
-- Data for Name: refund_requests; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refund_requests (refund_request_id, report_id, amount, status, admin_note, reviewed_by, created_at, reviewed_at) VALUES (1, 3, 150.00, 'approved', 'Refunding the 150 minutes after real docking time.', 2, '2026-11-06 13:10:00', '2026-11-07 11:00:00');
INSERT INTO public.refund_requests (refund_request_id, report_id, amount, status, admin_note, reviewed_by, created_at, reviewed_at) VALUES (2, 5, 5.00, 'pending', NULL, NULL, '2026-11-05 18:05:00', NULL);
INSERT INTO public.refund_requests (refund_request_id, report_id, amount, status, admin_note, reviewed_by, created_at, reviewed_at) VALUES (3, 6, 17.00, 'rejected', 'Ride was charged correctly.', 2, '2026-11-03 09:00:00', '2026-11-04 12:00:00');


--
-- Data for Name: rentals; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rentals (rental_id, user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES (1, 3, 1, 1, 2, '2026-11-01 09:00:00', '2026-11-01 09:18:00', 'completed', 3.20, 96, 384.00);
INSERT INTO public.rentals (rental_id, user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES (2, 4, 2, 2, 1, '2026-11-02 14:10:00', '2026-11-02 14:35:00', 'completed', 4.50, 135, 540.00);
INSERT INTO public.rentals (rental_id, user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES (3, 5, 5, 1, 3, '2026-11-03 08:00:00', '2026-11-03 08:12:00', 'completed', 2.10, 63, 252.00);
INSERT INTO public.rentals (rental_id, user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES (4, 3, 4, 3, 1, '2026-11-05 17:30:00', '2026-11-05 17:52:00', 'completed', 3.80, 114, 456.00);
INSERT INTO public.rentals (rental_id, user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES (5, 6, 6, 2, 2, '2026-11-06 10:00:00', '2026-11-06 13:00:00', 'completed', 1.40, 42, 168.00);
INSERT INTO public.rentals (rental_id, user_id, bike_id, start_station_id, end_station_id, start_time, end_time, status, distance_km, calories_burnt, co2_saved_g) VALUES (6, 4, 3, 1, NULL, '2026-11-14 18:30:00', NULL, 'active', NULL, NULL, NULL);


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.reports (report_id, user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES (1, 3, 7, NULL, 'damage', 'Front brake is not working at all.', NULL, 'open', NULL, NULL, '2026-11-08 12:00:00', NULL);
INSERT INTO public.reports (report_id, user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES (2, 4, 2, 2, 'problem', 'Seat kept sliding down during the ride.', NULL, 'resolved', 'Seat clamp tightened.', 1, '2026-11-02 14:40:00', '2026-11-03 10:00:00');
INSERT INTO public.reports (report_id, user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES (3, 6, NULL, 5, 'special_case', 'I docked at 10:40 but the lock did not click, I was charged 3 hours.', 'https://files.smartbike.eg/proof/5.jpg', 'resolved', 'Station log confirms docking at 10:40.', 2, '2026-11-06 13:10:00', '2026-11-07 11:00:00');
INSERT INTO public.reports (report_id, user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES (4, 5, 8, NULL, 'damage', 'Chain keeps slipping when going uphill.', NULL, 'resolved', 'Bike sent to maintenance.', 1, '2026-11-09 09:30:00', '2026-11-09 15:00:00');
INSERT INTO public.reports (report_id, user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES (5, 3, NULL, 4, 'special_case', 'App froze at the end, I think I paid a few extra minutes.', NULL, 'open', NULL, NULL, '2026-11-05 18:05:00', NULL);
INSERT INTO public.reports (report_id, user_id, bike_id, rental_id, report_type, description, proof_url, status, resolution_note, resolved_by, created_at, resolved_at) VALUES (6, 5, NULL, 3, 'special_case', 'I want a refund because the ride was short.', NULL, 'resolved', 'Normal ride, no system issue.', 2, '2026-11-03 09:00:00', '2026-11-04 12:00:00');


--
-- Data for Name: stations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.stations (station_id, name, address, latitude, longitude, capacity, created_at) VALUES (1, 'GIU Main Gate', 'GIU campus, main entrance', 30.018400, 31.739100, 10, '2026-11-14 22:00:52.189959');
INSERT INTO public.stations (station_id, name, address, latitude, longitude, capacity, created_at) VALUES (2, 'GIU Student Housing', 'GIU dorms entrance', 30.021300, 31.742600, 8, '2026-11-14 22:00:52.189959');
INSERT INTO public.stations (station_id, name, address, latitude, longitude, capacity, created_at) VALUES (3, 'Capital Park', 'Central park, south gate', 30.012700, 31.751800, 6, '2026-11-14 22:00:52.189959');
INSERT INTO public.stations (station_id, name, address, latitude, longitude, capacity, created_at) VALUES (4, 'R5 Plaza', 'R5 residential district', 30.025900, 31.733400, 2, '2026-11-14 22:00:52.189959');
INSERT INTO public.stations (station_id, name, address, latitude, longitude, capacity, created_at) VALUES (5, 'R7 District', 'R7 residential district', 30.006800, 31.729500, 6, '2026-11-14 22:00:52.189959');


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (1, 1, NULL, NULL, 'top_up', 100.00, 'visa', 'success', 100.00, '2026-10-31 20:00:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (2, 1, 1, NULL, 'charge', 23.00, NULL, 'success', 77.00, '2026-11-01 09:18:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (3, 1, 4, NULL, 'charge', 27.00, NULL, 'success', 50.00, '2026-11-05 17:52:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (4, 2, NULL, NULL, 'top_up', 50.00, 'instapay', 'success', 50.00, '2026-11-02 13:50:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (5, 2, 2, NULL, 'charge', 30.00, NULL, 'success', 20.00, '2026-11-02 14:35:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (6, 2, NULL, NULL, 'top_up', 200.00, 'mastercard', 'failed', 20.00, '2026-11-14 18:10:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (7, 2, NULL, NULL, 'top_up', 100.00, 'vodafone_cash', 'success', 120.00, '2026-11-14 18:15:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (8, 3, NULL, NULL, 'top_up', 40.00, 'vodafone_cash', 'success', 40.00, '2026-11-02 22:00:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (9, 3, 3, NULL, 'charge', 17.00, NULL, 'success', 23.00, '2026-11-03 08:12:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (10, 4, NULL, NULL, 'top_up', 200.00, 'visa', 'success', 200.00, '2026-11-06 09:45:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (11, 4, 5, NULL, 'charge', 185.00, NULL, 'success', 15.00, '2026-11-06 13:00:00');
INSERT INTO public.transactions (transaction_id, wallet_id, rental_id, refund_request_id, transaction_type, amount, payment_method, status, balance_after, created_at) VALUES (12, 4, NULL, 1, 'refund', 150.00, NULL, 'success', 165.00, '2026-11-07 11:00:00');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (1, 'Karim Adel', 'karim.admin@smartbike.eg', '01000000001', 'hash_admin_1', NULL, false, 'admin', '2026-11-14 22:00:52.189959');
INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (2, 'Nour Hassan', 'nour.admin@smartbike.eg', '01000000002', 'hash_admin_2', NULL, false, 'admin', '2026-11-14 22:00:52.189959');
INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (3, 'Omar Khaled', 'omar.khaled@mail.com', '01111111111', 'hash_rider_3', '30105150101234', true, 'rider', '2026-11-14 22:00:52.189959');
INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (4, 'Salma Mostafa', 'salma.m@mail.com', '01222222222', 'hash_rider_4', '30208210102345', true, 'rider', '2026-11-14 22:00:52.189959');
INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (5, 'Youssef Tarek', 'youssef.t@mail.com', '01033333333', 'hash_rider_5', '30011030103456', true, 'rider', '2026-11-14 22:00:52.189959');
INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (6, 'Mariam Ashraf', 'mariam.a@mail.com', '01544444444', 'hash_rider_6', '30303120104567', true, 'rider', '2026-11-14 22:00:52.189959');
INSERT INTO public.users (user_id, full_name, email, phone, password_hash, national_id, is_id_verified, role, created_at) VALUES (7, 'Ali Samy', 'ali.samy@mail.com', '01155555555', 'hash_rider_7', '30409250105678', true, 'rider', '2026-11-14 22:00:52.189959');


--
-- Data for Name: wallets; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.wallets (wallet_id, user_id, balance, updated_at) VALUES (1, 3, 50.00, '2026-11-14 22:00:52.189959');
INSERT INTO public.wallets (wallet_id, user_id, balance, updated_at) VALUES (2, 4, 120.00, '2026-11-14 22:00:52.189959');
INSERT INTO public.wallets (wallet_id, user_id, balance, updated_at) VALUES (3, 5, 23.00, '2026-11-14 22:00:52.189959');
INSERT INTO public.wallets (wallet_id, user_id, balance, updated_at) VALUES (4, 6, 165.00, '2026-11-14 22:00:52.189959');
INSERT INTO public.wallets (wallet_id, user_id, balance, updated_at) VALUES (5, 7, 0.00, '2026-11-14 22:00:52.189959');


--
-- Name: bike_locations_bike_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bike_locations_bike_location_id_seq', 10, true);


--
-- Name: bikes_bike_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bikes_bike_id_seq', 9, true);


--
-- Name: maintenance_flags_maintenance_flag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.maintenance_flags_maintenance_flag_id_seq', 2, true);


--
-- Name: refund_requests_refund_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refund_requests_refund_request_id_seq', 3, true);


--
-- Name: rentals_rental_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rentals_rental_id_seq', 6, true);


--
-- Name: reports_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reports_report_id_seq', 6, true);


--
-- Name: stations_station_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stations_station_id_seq', 5, true);


--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transactions_transaction_id_seq', 12, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 7, true);


--
-- Name: wallets_wallet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wallets_wallet_id_seq', 5, true);


--
-- Name: bike_locations bike_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bike_locations
    ADD CONSTRAINT bike_locations_pkey PRIMARY KEY (bike_location_id);


--
-- Name: bikes bikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bikes
    ADD CONSTRAINT bikes_pkey PRIMARY KEY (bike_id);


--
-- Name: bikes bikes_qr_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bikes
    ADD CONSTRAINT bikes_qr_code_key UNIQUE (qr_code);


--
-- Name: maintenance_flags maintenance_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_flags
    ADD CONSTRAINT maintenance_flags_pkey PRIMARY KEY (maintenance_flag_id);


--
-- Name: refund_requests refund_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_pkey PRIMARY KEY (refund_request_id);


--
-- Name: refund_requests refund_requests_report_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_report_id_key UNIQUE (report_id);


--
-- Name: rentals rentals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rentals
    ADD CONSTRAINT rentals_pkey PRIMARY KEY (rental_id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (report_id);


--
-- Name: stations stations_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_name_key UNIQUE (name);


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (station_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: transactions transactions_refund_request_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_refund_request_id_key UNIQUE (refund_request_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_national_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_national_id_key UNIQUE (national_id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (wallet_id);


--
-- Name: wallets wallets_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_key UNIQUE (user_id);


--
-- Name: idx_bike_locations_bike_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bike_locations_bike_time ON public.bike_locations USING btree (bike_id, recorded_at);


--
-- Name: idx_bikes_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bikes_station ON public.bikes USING btree (station_id);


--
-- Name: idx_bikes_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bikes_status ON public.bikes USING btree (status);


--
-- Name: idx_rentals_start_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rentals_start_station ON public.rentals USING btree (start_station_id);


--
-- Name: idx_reports_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reports_status ON public.reports USING btree (status, created_at);


--
-- Name: idx_transactions_wallet_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_wallet_time ON public.transactions USING btree (wallet_id, created_at DESC);


--
-- Name: uq_flags_one_open_per_bike; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_flags_one_open_per_bike ON public.maintenance_flags USING btree (bike_id) WHERE ((status)::text = 'open'::text);


--
-- Name: uq_rentals_one_active_per_bike; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_rentals_one_active_per_bike ON public.rentals USING btree (bike_id) WHERE ((status)::text = 'active'::text);


--
-- Name: uq_rentals_one_active_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_rentals_one_active_per_user ON public.rentals USING btree (user_id) WHERE ((status)::text = 'active'::text);


--
-- Name: bike_locations bike_locations_bike_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bike_locations
    ADD CONSTRAINT bike_locations_bike_id_fkey FOREIGN KEY (bike_id) REFERENCES public.bikes(bike_id) ON DELETE CASCADE;


--
-- Name: bikes bikes_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bikes
    ADD CONSTRAINT bikes_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(station_id) ON DELETE SET NULL;


--
-- Name: maintenance_flags maintenance_flags_bike_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_flags
    ADD CONSTRAINT maintenance_flags_bike_id_fkey FOREIGN KEY (bike_id) REFERENCES public.bikes(bike_id) ON DELETE RESTRICT;


--
-- Name: maintenance_flags maintenance_flags_flagged_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maintenance_flags
    ADD CONSTRAINT maintenance_flags_flagged_by_fkey FOREIGN KEY (flagged_by) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: refund_requests refund_requests_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(report_id) ON DELETE CASCADE;


--
-- Name: refund_requests refund_requests_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_requests
    ADD CONSTRAINT refund_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: rentals rentals_bike_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rentals
    ADD CONSTRAINT rentals_bike_id_fkey FOREIGN KEY (bike_id) REFERENCES public.bikes(bike_id) ON DELETE RESTRICT;


--
-- Name: rentals rentals_end_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rentals
    ADD CONSTRAINT rentals_end_station_id_fkey FOREIGN KEY (end_station_id) REFERENCES public.stations(station_id) ON DELETE RESTRICT;


--
-- Name: rentals rentals_start_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rentals
    ADD CONSTRAINT rentals_start_station_id_fkey FOREIGN KEY (start_station_id) REFERENCES public.stations(station_id) ON DELETE RESTRICT;


--
-- Name: rentals rentals_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rentals
    ADD CONSTRAINT rentals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: reports reports_bike_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_bike_id_fkey FOREIGN KEY (bike_id) REFERENCES public.bikes(bike_id) ON DELETE RESTRICT;


--
-- Name: reports reports_rental_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rentals(rental_id) ON DELETE RESTRICT;


--
-- Name: reports reports_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: reports reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_refund_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_refund_request_id_fkey FOREIGN KEY (refund_request_id) REFERENCES public.refund_requests(refund_request_id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_rental_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES public.rentals(rental_id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_wallet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallets(wallet_id) ON DELETE RESTRICT;


--
-- Name: wallets wallets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


