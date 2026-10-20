# Data Dictionary

## Booking

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Booking_id | INT | PK | Unique number id for each booking | 1 |
| Stay_start | DATE | NOT NULL | Check-in date | 20-12-2024 |
| Stay_end | DATE | NOT NULL | Check-out date | 30-12-2024 |
| Number_guests | INT | NOT NULL | Number of guests per booking | 2 |
| Guest_id | INT | FK, NOT NULL | Id of the guest making the booking | 1 |
| Staff_id | INT | FK, NULL | The staff who reserved the booking | 1 |

## Booking Room

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Booking_id | INT | CPK, FK | Links to the booking table | 1 |
| Room_id | INT | CPK, FK | Links to the room table | 1 |

## Room

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Room_id | INT | PK | Id for each room | 1 |
| Floor_no | INT (10) | NOT NULL | Floor number in which the room exists | 3 (floor number 3) |
| Is_booked | TINYINT (1) | NOT NULL | Is the room booked or not? | 1 (means booked) |
| Type_id | INT | FK, NOT NULL | Links to room type table | 1 |

## Staff

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Staff_id | INT | PK | Employee id | 1 |
| First_name | VARCHAR (50) | NOT NULL | Employee's first name | Khaled |
| Last_name | VARCHAR (50) | NOT NULL | Employee's last name | Elsawy |
| Gender | VARCHAR (10) | NOT NULL | Employee's gender | Male |
| Salary | DECIMAL (10) | NOT NULL | Employee's salary | 10000.00 |
| Phone_no | VARCHAR (20) | NULL | Employee's contact number. | +201125252525 |
| Manager_id | INT | FK, NULL | Id for the person who manages other employees | 2 |

## Guest

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Guest_id | INT | PK | Id for the guest | 1 |
| First_name | VARCHAR (50) | NOT NULL | Guest's first name | Ahmed |
| Last_name | VARCHAR (50) | NOT NULL | Guest's last name | Hazem |
| Gender | VARCHAR (10) | NOT NULL | Guest's gender | Male |
| Email | VARCHAR (50) | NOT NULL | Guest's Email address | ahmedd@gmail.com |
| PHONE_NO | VARCHAR (20) | NULL | Guest phone number | +201125252525 |

## Payment

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Payment_id | INT | PK | Id for each payment | 1 |
| Amount | DECIMAL (10) | NOT NULL | The amount of money paid | 500.00 |
| Booking_id | INT | FK, NOT NULL | Id for each booking | 1 |
| Method name | VARCHAR (20) | NOT NULL | The name of each method | Cash, Credit, Instapay |

## Room Type

| Data type | Constraints | Description | Example |
|-----------|-------------|-------------|---------|
| Type_id | INT | PK | Id for each room type | 1 |
| Type_name | VARCHAR (15) | NOT NULL | The name of each room type | Single, double, grand, suite |
| Price | DECIMAL (10) | NOT NULL | The price of each type | 300.00 |
| capacity | INT | NOT NULL | The maximum capacity of each room | 3 |
