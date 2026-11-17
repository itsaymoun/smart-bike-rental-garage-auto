# Smart Bike Rental App - Last Mile

Software Engineering - GIU Cairo - Milestone 2

## Team
| Name | ID | Role in team |
|------|----|--------------|
| Ahmed Ayman | 19005075 | Team leader |
| Omar Mohamed | 19003512 | Team Leader |
| Noureldein Salah | 19008943 | Member |
| Ahmed mohamed | 19007447 | Member |
| Mamdouh Essam | 19001231 | Member |
| omar hany | 19004634 | Member |
| Mousa Moustafa | 19008296 | Member |
| Mahmoud elsentawy | 19003579 | Member |

## ERD
**Editable diagram:** [erd.drawio](https://github.com/itsaymoun/smart-bike-rental-garage-auto/blob/main/docs/erd.drawio)

**Open in draw.io:** [Edit the ERD](https://app.diagrams.net/#G1xhpmhZv5yY-y-C4Yi1NNx9AJtsWVAIYd#%7B%22pageId%22%3A%22erd%22%7D)

**ERD image:** [erd.png](https://github.com/itsaymoun/smart-bike-rental-garage-auto/blob/main/docs/erd.png)

The ERD uses Crow's Foot notation to represent relationships and cardinalities. Relationships are named, and cardinalities are shown at both ends (`1`, `0..1`, and `0..N`).

The diagram uses the following conventions:

- **PK:** Primary key (bold and underlined).
- *FK:* Foreign key (italic).
- **UQ:** Unique attribute.

## Traceability: entities to user stories
| Entity | Justified by user stories |
|--------|---------------------------|
| users | A-01, R-01, R-02, A-06, A-08 |
| wallets | R-08, R-10, A-03 |
| stations | R-03, R-04, R-15, A-04, A-09, A-11 |
| bikes | R-06, A-02, A-04, A-07, A-10, A-11 |
| rentals | R-05, R-06, R-07, R-11, R-16, R-17, A-03, A-04, A-05, A-09 |
| bike_locations | A-02, R-17 |
| transactions | R-07, R-10, R-12, A-03, A-06 |
| reports | R-13, R-14, A-06, A-07 |
| refund_requests | R-14, A-06 |
| maintenance_flags | A-07, A-08, A-10 |

### How the Must-have stories are covered
| Story | Where it lives in the schema |
|-------|------------------------------|
| A-01 separate admin account | `users.role` ('rider' / 'admin') |
| A-03 rent only with enough balance | `wallets.balance`, checked before a row is added to `rentals` |
| A-04 bikes only returned to stations | `rentals.end_station_id` is required once a rental is completed (`chk_rentals_end_state`) |
| A-05 locking in the dock ends the rental | `rentals.status`, `end_time`, `end_station_id` are set together |
| A-07 see reports and damaged bikes | `reports` (status + date), `bikes.status = 'damaged'` |
| A-08 flag bikes for maintenance | `maintenance_flags` (bike, reason, admin, date) |
| A-11 dashboard of all bikes and stations | `bikes.status`, `bikes.station_id`, `stations` |
| R-01 register with national ID | `users.national_id` (14 digits, unique) and `is_id_verified` |
| R-02 secure login | `users.email` (unique) + `password_hash` (we never store the plain password) |
| R-03 stations on a GPS map | `stations.latitude`, `stations.longitude` |
| R-04 number of bikes per station | count of `bikes` per `station_id` |
| R-05 timer from scan | `rentals.start_time` |
| R-06 unlock with QR | `bikes.qr_code` (unique); one active rental per bike (partial unique index) |
| R-08 wallet with balance | `wallets` |
| R-10 top up through a payment service | `transactions` with `payment_method` and `status` (a failed top-up doesn't change the balance) |
| R-13 report a damaged bike / problem | `reports` (a damage/problem report must name a bike) |
| R-15 live map, full stations | `stations.capacity` compared with the bikes docked there |

### Design notes
- **Roles:** the backlog only has Rider (R-xx) and Admin (A-xx) stories, so both roles live in one `users` table with a `role` column. We didn't add a Company entity because no story in our backlog needs one.
- **R-09 (reserve a bike)** is a *Won't* story, so there is no reservations table. Renting is first come, first served.
- **Many-to-many:** riders and bikes are many-to-many over time. `rentals` is the associative entity that resolves it.
- **Derived values aren't stored:** the bike count per station, the trending stations (A-09), the rented / in-maintenance counts (A-10) and the rental duration all come from queries. This keeps the design in 3NF.
- **Trip route (R-17):** `bike_locations` keeps the tracker points of every bike. A trip's route is that bike's points between the rental's `start_time` and `end_time`, so we didn't add a rental FK there (it would repeat `bike_id`).
- **Receipt (R-07):** built from the rental plus its `charge` transaction. `balance_after` gives the remaining balance at that moment.
- **Admin-only columns** (`reports.resolved_by`, `refund_requests.reviewed_by`, `maintenance_flags.flagged_by`) point to `users`. The app checks that the user is an admin.
- **Push notifications (R-11 AC2)** and live map updates (A-02, A-11, R-15) are app behaviour. They read from these tables but don't need their own table.

## Database
- DBMS: PostgreSQL 17
- Database name: smart_bike_rental
- Scripts are in the `schema/` folder. Run them in numeric order:
  1. `01_create_tables.sql`: the 10 tables, with PK, FK (each with a commented `ON DELETE` rule), `NOT NULL`, `UNIQUE`, `DEFAULT` and `CHECK`
  2. `02_constraints_indexes.sql`: partial unique indexes (one active rental per bike / per rider, one open maintenance flag per bike) and indexes for the main queries
  3. `03_seed_data.sql`: sample rows for every table
- The pricing in the seed data is an assumption for testing only: 5 EGP to unlock, 1 EGP per minute, and a minimum balance of 30 EGP to start a ride.
- We tested the scripts on an empty database and tried to break the constraints on purpose. See [schema/README.md](schema/README.md).

### Full database export
[`database/smart_bike_rental.sql`](database/smart_bike_rental.sql) is a full export of the database (pg_dump from PostgreSQL 17): all 10 tables, constraints, indexes and the sample data, in one file.

To restore it, create an empty database called `smart_bike_rental`, then either:
- **pgAdmin:** right-click the database > Query Tool > open `smart_bike_rental.sql` > Run (F5)
- **psql:** `psql -U postgres -d smart_bike_rental -f database/smart_bike_rental.sql`
