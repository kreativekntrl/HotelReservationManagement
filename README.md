# Hotel Billing & Reservation Management System

A relational database solution built with **Microsoft SQL Server and T-SQL** for managing hotel guests, rooms, reservations, check-ins, check-outs, and billing.

The system centralizes hotel reservation and billing data while using **primary keys, foreign key constraints, validation, transactions, and stored procedures** to enforce business rules and maintain data integrity.

---

## 📋 Project Overview

The Hotel Billing & Reservation Management System is designed for a boutique hotel or bed and breakfast that needs a centralized solution for managing front-desk operations.

A typical hotel reservation involves several connected processes:

1. Creating a guest profile
2. Creating a reservation
3. Assigning a room
4. Checking the guest in
5. Creating and managing the guest's invoice
6. Adding additional charges during the stay
7. Checking the guest out
8. Finalizing the guest's bill

Without a structured database system, these processes can lead to duplicate reservations, inaccurate room statuses, incorrect billing, incomplete guest information, and disconnected invoice records.

This project addresses those problems by centralizing the data and encapsulating the main business workflows inside SQL Server stored procedures.

---

## 🎯 Project Goals

The main goals of the system are to:

- Maintain accurate guest information
- Prevent duplicate guest profiles
- Manage room availability and status
- Prevent overlapping reservations
- Connect guests to their reservations and rooms
- Automate check-in and check-out processing
- Automatically create invoices
- Track individual invoice charges
- Calculate invoice subtotals, taxes, and totals
- Prevent modifications to invoices after payment
- Reduce repetitive manual SQL processing
- Maintain data integrity across related tables

---

## 🏗️ Architecture

The project uses a **2-tier database architecture**.

### Tier 1 — SQL Server Database

The first tier contains the relational database and its permanent data.

It consists of five primary tables:

- `Guests`
- `Rooms`
- `Reservations`
- `Invoices`
- `InvoiceDetails`

Primary keys uniquely identify records, while foreign key constraints maintain relationships between the tables.

### Tier 2 — Stored Procedures

The second tier contains the business logic implemented using T-SQL stored procedures.

The stored procedures provide controlled operations for:

- Creating guests
- Creating reservations
- Processing check-ins
- Managing invoice charges
- Editing or removing invoice charges
- Processing check-outs and final billing

This separation allows a future web-based application to interact with the database through controlled stored procedures rather than directly modifying tables.

---

## 🗃️ Database Schema

The database contains five main entities.

```text
Guests
  │
  │ 1-to-many
  ▼
Reservations
  │
  ├──────────────► Rooms
  │
  │ 1-to-1
  ▼
Invoices
  │
  │ 1-to-many
  ▼
InvoiceDetails
```

### Guests

Stores guest profile information.

Typical attributes include:

- `GuestID` — Primary Key
- First Name
- Last Name
- Email
- Phone Number

Guest IDs are automatically generated, and email addresses are required to be unique.

---

### Rooms

Stores hotel room information.

Typical attributes include:

- `RoomID` — Primary Key
- Room Number
- Room Type
- Base Rate
- Room Status

Room status allows the system to track whether a room is:

- Available
- Occupied
- Needs Cleaning
- Under Maintenance
- Decommissioned

---

### Reservations

Connects guests to rooms and records their reservation dates.

Typical attributes include:

- `ReservationID` — Primary Key
- `GuestID` — Foreign Key
- `RoomID` — Foreign Key
- Check-In Date
- Check-Out Date
- Reservation Status

The database prevents invalid guest or room references through foreign key constraints.

The reservation logic also checks for overlapping reservations before a booking is created.

---

### Invoices

Stores the financial information associated with a reservation.

Typical attributes include:

- `InvoiceID` — Primary Key
- `ReservationID` — Foreign Key
- Subtotal
- Tax Amount
- Total Amount
- Payment Status

The invoice remains connected to the reservation throughout the guest's stay.

---

### InvoiceDetails

Stores individual charges that make up an invoice.

Typical attributes include:

- `InvoiceDetailID` — Primary Key
- `InvoiceID` — Foreign Key
- Description
- Amount
- Tax Rate

For example, an invoice could contain:

```text
Room Charge       $150.00
Hotel Service      $25.00
Restaurant Charge  $40.00
---------------------------
Subtotal          $215.00
Tax                $21.50
Total              $236.50
```

---

## 🔗 Table Relationships

The database uses primary keys and foreign key constraints to maintain referential integrity.

### Guests → Reservations

**One-to-many**

One guest can have many reservations over time.

```text
Guests.GuestID
       │
       │ FK
       ▼
Reservations.GuestID
```

### Rooms → Reservations

**One-to-many**

A room can be associated with multiple reservations over time, while each reservation is assigned to one room.

```text
Rooms.RoomID
     │
     │ FK
     ▼
Reservations.RoomID
```

### Reservations → Invoices

A reservation is associated with its invoice.

```text
Reservations.ReservationID
          │
          │ FK
          ▼
Invoices.ReservationID
```

### Invoices → InvoiceDetails

**One-to-many**

One invoice can contain multiple individual charges.

```text
Invoices.InvoiceID
       │
       │ FK
       ▼
InvoiceDetails.InvoiceID
```

These relationships allow the database to maintain the complete chain:

**Guest → Reservation → Room → Invoice → Invoice Details**

---

## ⚙️ Stored Procedures

The main business processes are implemented using stored procedures.

### `AddNewGuest`

Creates a new guest profile.

The procedure:

- Accepts guest information as parameters
- Validates required input
- Checks for an existing email address
- Prevents duplicate guest records
- Inserts the new guest
- Automatically generates the `GuestID`

---

### `AddNewReservation`

Creates a reservation for an existing guest.

The procedure:

- Validates that the guest exists
- Validates check-in and check-out dates
- Checks room availability
- Checks room status
- Prevents overlapping reservations
- Creates the reservation record

---

### `ProcessCheckIn`

Processes a guest's arrival.

The procedure:

1. Verifies that the reservation exists
2. Checks that it has not already been checked in
3. Checks that the reservation has not been cancelled
4. Retrieves the assigned room and base rate
5. Updates the reservation to `Checked-In`
6. Updates the room to `Occupied`
7. Creates an invoice
8. Adds the room's base rate as an invoice detail

The room's base rate is retrieved directly from the `Rooms` table rather than manually entered during check-in.

---

### `AddInvoiceLineItem`

Adds an additional charge to an existing invoice.

The procedure:

- Validates the invoice
- Validates the charge amount
- Accepts an optional tax rate
- Creates a new invoice detail
- Updates the invoice subtotal
- Updates the tax amount
- Updates the final invoice total

This allows additional hotel services or charges to be recorded during a guest's stay.

---

### `RemoveOrEditInvoiceLineItems`

Allows authorized staff to modify invoice charges while the invoice is still pending.

The procedure supports:

- Adjusting an existing charge
- Deleting an existing charge

Before making changes, it verifies that the invoice has not already been paid.

This prevents historical invoices from being altered after payment.

---

### `ProcessCheckOutAndBilling`

Handles the final guest checkout.

The procedure:

1. Verifies that the reservation exists
2. Checks that checkout has not already been completed
3. Verifies that an invoice exists
4. Updates the room status to `Needs Cleaning`
5. Updates the reservation status to `Completed`
6. Updates the invoice payment status to `Paid`

This completes the guest's reservation and billing workflow.

---

## 🔄 Business Workflow

The primary workflow of the system is:

```text
Add Guest
    │
    ▼
Create Reservation
    │
    ▼
Process Check-In
    │
    ├──► Room → Occupied
    │
    └──► Invoice Created
              │
              ▼
       Add Invoice Charges
              │
              ▼
       Process Check-Out
              │
              ├──► Reservation → Completed
              │
              ├──► Room → Needs Cleaning
              │
              └──► Invoice → Paid
```

This workflow ensures that changes to related entities happen as part of the appropriate business process.

---

## 🛡️ Data Integrity & Business Rules

The database uses several mechanisms to maintain data quality.

### Primary Keys

Primary keys uniquely identify records in each table.

Examples:

```text
GuestID
RoomID
ReservationID
InvoiceID
InvoiceDetailID
```

### Foreign Keys

Foreign key constraints maintain relationships between related tables and prevent invalid references.

### Unique Constraints

Guest email addresses are unique to prevent duplicate guest profiles.

### Validation

Stored procedures validate input before performing database modifications.

### Reservation Conflict Checking

The reservation procedure checks for overlapping bookings to help prevent double-booking a room.

### Invoice Protection

Invoice line items cannot be modified or deleted once the associated invoice has been marked as paid.

### Transactional Processing

Multi-step business workflows are designed to maintain atomicity and consistency so related database changes are processed together.

---

## 💻 Technologies Used

| Technology | Purpose |
|---|---|
| Microsoft SQL Server | Database management system |
| T-SQL | Database programming language |
| SQL Server Management Studio (SSMS) | Database development and testing |
| Stored Procedures | Business logic and controlled data processing |
| Relational Database Design | Data organization and relationships |
| ERD | Database schema and relationship modelling |

---

## 📁 Suggested Repository Structure

```text
Hotel-Billing-Reservation-System/
│
├── README.md
│
├── SQL/
│   ├── DatabaseSchema.sql
│   ├── SampleData.sql
│   └── StoredProcedures.sql
│
├── ERD/
│   └── HotelDatabaseERD.png
│
├── Screenshots/
│   ├── Guests.png
│   ├── Rooms.png
│   ├── Reservations.png
│   ├── Invoices.png
│   └── InvoiceDetails.png
│
└── Documentation/
    └── ProjectReport.pdf
```

The exact folder structure can be adjusted depending on the files included in the repository.

---

## 🚀 Getting Started

### Prerequisites

To run this project, you will need:

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)

### Installation

1. Clone or download the repository.

2. Open **SQL Server Management Studio**.

3. Connect to your SQL Server instance.

4. Open the database schema SQL script.

5. Execute the script to create the database and tables.

6. Run the sample data script if included.

7. Execute the stored procedure script.

8. Use the provided test queries to demonstrate the database workflow.

---

## 🧪 Example Workflow

After setting up the database, the system can be tested using the following sequence:

```text
1. Add a guest
2. Attempt to add a duplicate guest
3. Create a reservation
4. Attempt an invalid or overlapping reservation
5. Process the guest check-in
6. Verify room and reservation status
7. Verify that an invoice was created
8. Add an invoice line item
9. Verify updated invoice totals
10. Process guest checkout
11. Verify reservation status
12. Verify room status
13. Verify invoice payment status
```

This demonstrates both the successful workflow and the database's error checking.

---

## 📊 Example End-to-End Process

A typical guest lifecycle looks like this:

### 1. Guest Created

```text
Guest
Status: Active
```

### 2. Reservation Created

```text
Reservation
Status: Reserved
Room
Status: Available
```

### 3. Guest Checks In

```text
Reservation
Status: Checked-In

Room
Status: Occupied

Invoice
Status: Pending
```

### 4. Additional Charges Added

```text
InvoiceDetails
Room Charge
+ Additional Services
+ Other Charges
```

The invoice totals are recalculated.

### 5. Guest Checks Out

```text
Reservation
Status: Completed

Room
Status: Needs Cleaning

Invoice
Status: Paid
```

---

## 🔮 Future Improvements

The current database provides a foundation for a larger hotel management application.

Potential future improvements include:

- Web-based front-end interface
- Employee authentication and authorization
- Guest self-service reservation management
- Reservation cancellation
- Reservation extensions
- Automated email confirmations
- Online payment processing
- Room availability search
- Occupancy reports
- Revenue reports
- Reservation trend reports
- Outstanding payment reports
- Housekeeping management
- Maintenance tracking
- Audit logging for billing changes

A future web application could interact with the database through the existing stored procedures, allowing the database business logic to remain centralized.

---

## 🎓 Academic Project

This project was developed as a database design and implementation project demonstrating:

- Relational database design
- Entity Relationship Diagrams
- Primary and foreign keys
- Referential integrity
- SQL Server
- T-SQL
- Stored procedures
- Input validation
- Business rule enforcement
- Transactional processing
- Reservation management
- Invoice and billing management

---

## 📄 License

This project was created for educational purposes.

If you would like to reuse or adapt the project, please provide appropriate attribution.
