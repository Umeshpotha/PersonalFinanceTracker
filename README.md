<<<<<<< HEAD
# PersonalFinanceTracker
=======
# Personal Finance Tracker (SQL-Only Project)

A portfolio-ready, SQL-centric project to track income, expenses, budgets, investments, and debts — with reports and simple forecasting.  
**Engine target:** MySQL 8.0+

## Features
- Categories & subcategories for **Income** and **Expense**
- **Accounts** (cash/bank/credit-card/loan/investment)
- **Transactions** with references to accounts & categories
- **Budgets** per category per month
- **Investments** (trades + latest prices) → P&L & holdings
- **Debts/Loans** with payment tracking
- Views for monthly summaries and budget tracking
- Stored procedures for monthly budget report and savings forecast
- Sample data included

## Quickstart (MySQL 8.0+)
```bash
# 1) Create database (optional)
mysql -u root -p -e "CREATE DATABASE finance_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

# 2) Load schema
mysql -u root -p finance_db < database_schema.sql

# 3) Load sample data
mysql -u root -p finance_db < sample_data.sql

# 4) (Optional) Create views, triggers, and procedures
mysql -u root -p finance_db < views.sql
mysql -u root -p finance_db < triggers.sql
mysql -u root -p finance_db < procedures.sql

# 5) Run reports
mysql -u root -p finance_db < reports.sql
```

## Files
- `database_schema.sql` — tables, constraints, indexes
- `sample_data.sql` — realistic sample rows for quick demos
- `views.sql` — handy views (monthly summary, budget vs. spend, holdings)
- `triggers.sql` — account balance maintenance on transaction changes
- `procedures.sql` — stored procedures for reports & forecasting
- `reports.sql` — ready-made analytical queries
- `LICENSE` — MIT

## ER (Textual)
```
Categories (CategoryID PK) --< Transactions >-- Accounts (AccountID PK)
Categories (parent -> CategoryID)  1..* subcategories
Budgets (per Category, per Month/Year)
Investments (Symbol) --< InvestmentTrades >-- Accounts (type=Investment)
InvestmentPrices (Symbol, PriceDate) latest-> P&L
Debts (DebtID PK) --< DebtPayments >-- Transactions
```

## Notes
- Amounts in `Transactions.Amount` are **positive**, direction is inferred by category type.
- Balances are maintained via triggers (INSERT/UPDATE/DELETE on `Transactions`). See `triggers.sql`.
- Forecasting is intentionally simple (average savings × months). Extend as you wish.
- Tested on MySQL 8.0; for PostgreSQL, adjust `AUTO_INCREMENT`, `ENUM`, and trigger syntax.
>>>>>>> 14d92e0 (PFT - Final commit)
