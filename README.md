# Music E-Commerce: Database Management System
A comprehensive relational database designed to manage the end-to-end operations of an online music store specializing in CDs, vinyl records, musical instruments, and accessories. The system accurately models real-world commercial flows, integrating supply chain logistics, customer relationship management (CRM), and targeted marketing strategies.

The primary goal of this project is to ensure strict data consistency, enforce complex business rules, and automate daily store operations utilizing advanced SQL and PL/SQL mechanisms (Oracle Database).

# 🎯 Project Objectives & Technical Scope
Design and implementation of a fully normalized relational model (3NF).

Advanced usage of `SQL` and `PL/SQL` to engineer backend business logic.

Implementation of robust mechanisms for audit, error handling, and process automation through triggers.

Generation of complex reports and automated workflows using PL/SQL `packages`.

Containerized database deployment using `Docker` for consistent testing environments.

# Database Structure & Business Modules
The database schema integrates the essential commercial flows through the following entities:

## 1. Supply Chain & Inventory
`FURNIZOR` (Suppliers): Stores supplier details, fiscal codes, and contact information.

`DEPOZIT` (Warehouses): Manages physical storage locations.

`APROVIZIONARE` (Associative): Tracks exactly which products are supplied by which vendor to specific warehouses, including acquisition prices and dates.

## 2. Product Catalog
`PRODUS` (Products): Core entity storing item details, current stock levels, and list prices.

`ARTIST` & `PRODUS_ARTIST`: Manages creators (musicians, bands) and their specific roles for each product.

`CATEGORIE`: Classifies products (e.g., Vinyl, Instruments, Accessories).

## 3. CRM & Order Processing
`CLIENT` & `ADRESA`: Manages user profiles, contact info, and multiple delivery addresses.

`COMANDA` & `DETALII_COMANDA`: Tracks customer orders, statuses, and specific items purchased (with historical pricing to maintain financial integrity).

`LIVRARE`: Manages shipping details, estimated dates, and AWBs.

`RECENZIE`: Stores customer reviews, ratings, and comments for purchased products.

## 4. Marketing & Promotions
`CAMPANIE`: Defines promotional campaigns (start/end dates, standard discounts).

`PRODUS_CAMPANIE`: Links specific products to active campaigns for special pricing.

## Implemented Functionalities (PL/SQL)
The project goes beyond simple data storage by engineering backend business logic directly into the database.

## Advanced PL/SQL Subprograms
Bulk Order Processing (Collections): A procedure utilizing all three types of collections (VARRAY, Nested Table, and Associative Array) to process bulk orders and apply dynamic discounts during high-traffic sales events (e.g., Black Friday).

Targeted Marketing (Cursors): A procedure implementing two types of cursors, including a dependent parameterized cursor, to iterate through customer purchase histories and determine eligibility for personalized promotional campaigns.

Cart Valuation (Functions): A complex function using three tables (COMANDA, DETALII_COMANDA, PRODUS) within a single SQL statement to calculate the final value of an order, including full exception handling for edge cases.

Supply Chain Analytics (Complex Procedures): A procedure joining five tables (FURNIZOR, APROVIZIONARE, PRODUS, DEPOZIT, CATEGORIE) to generate an acquisition report, implementing custom exceptions if a supplier has no recent activity.

## Database Triggers for Automation
Statement-level DML Trigger (Business Hours): Restricts invoice and order modifications outside of standard business hours.

Forbids DML operations on non-working days (weekends/holidays).

Logs all unauthorized attempts into a security audit table.

Row-level DML Trigger (Compound Trigger): * Automatically updates the stoc_curent in the PRODUS table whenever an order is placed, updated, or deleted.

Handles client orders and supplier restocks differently.

Specifically designed as a Compound Trigger to prevent the classic mutating table error (ORA-04091).

DDL Trigger (Schema Protection): * Audits all DDL operations (CREATE, ALTER, DROP) performed on the schema.

Prevents the accidental deletion of critical application tables (e.g., CLIENT, COMANDA).

## Audit & Error Handling
CODURI_EROARE: A centralized catalog table storing custom error codes and their descriptions.

LOG_EROARE: A dedicated table for logging failed executions and application errors using Autonomous Transactions (PRAGMA AUTONOMOUS_TRANSACTION), ensuring that errors are recorded even if the main transaction is rolled back.

AUDIT_OPERATII_LDD: Full audit trail for schema-level DDL modifications.

## PL/SQL Package: Store Replenishment Manager
A comprehensive PL/SQL package designed to automate the e-commerce platform's inventory and supply chain logic.

## Core Functionalities:

Identification of music products with critical stock levels across all warehouses.

Estimation of recent consumption and future demand based on client order history.

Generation and permanent storage of an automated replenishment report for suppliers.

## Advanced Techniques Used:

Implementation of complex data types (OBJECT, NESTED TABLE).

Use of Dynamic Cursors (REF CURSOR) to generate flexible queries based on user input parameters.

Grouping related functions and procedures into a cohesive business workflow.
