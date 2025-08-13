-- database_schema.sql
-- Engine: MySQL 8.0+

DROP TABLE IF EXISTS DebtPayments;
DROP TABLE IF EXISTS Debts;
DROP TABLE IF EXISTS InvestmentPrices;
DROP TABLE IF EXISTS InvestmentTrades;
DROP TABLE IF EXISTS Investments;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Budgets;
DROP TABLE IF EXISTS Accounts;
DROP TABLE IF EXISTS Categories;

-- Master tables
CREATE TABLE Categories (
  CategoryID INT PRIMARY KEY AUTO_INCREMENT,
  CategoryName VARCHAR(80) NOT NULL,
  Type ENUM('Income','Expense') NOT NULL,
  ParentCategoryID INT NULL,
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
    ON DELETE SET NULL
);
CREATE INDEX idx_categories_type ON Categories(Type);
CREATE UNIQUE INDEX ux_categories_name_type ON Categories(CategoryName, Type);

CREATE TABLE Accounts (
  AccountID INT PRIMARY KEY AUTO_INCREMENT,
  AccountName VARCHAR(80) NOT NULL,
  AccountType ENUM('Cash','Bank','CreditCard','Loan','Investment') NOT NULL,
  CurrentBalance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  OpenDate DATE DEFAULT (CURRENT_DATE),
  IsActive TINYINT(1) NOT NULL DEFAULT 1
);
CREATE UNIQUE INDEX ux_accounts_name ON Accounts(AccountName);
CREATE INDEX idx_accounts_type ON Accounts(AccountType);

-- Budget for a month & category (Expense budgets typically)
CREATE TABLE Budgets (
  BudgetID INT PRIMARY KEY AUTO_INCREMENT,
  CategoryID INT NOT NULL,
  Year INT NOT NULL,
  Month INT NOT NULL CHECK (Month BETWEEN 1 AND 12),
  Amount DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_budgets_category
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
    ON DELETE CASCADE,
  CONSTRAINT ux_budgets UNIQUE (CategoryID, Year, Month)
);

-- Transactions
CREATE TABLE Transactions (
  TransactionID INT PRIMARY KEY AUTO_INCREMENT,
  AccountID INT NOT NULL,
  CategoryID INT NOT NULL,
  Amount DECIMAL(14,2) NOT NULL CHECK (Amount >= 0),
  TxnDate DATE NOT NULL,
  Notes VARCHAR(255),
  CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_txn_account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
  CONSTRAINT fk_txn_category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
CREATE INDEX idx_txn_date ON Transactions(TxnDate);
CREATE INDEX idx_txn_category ON Transactions(CategoryID);
CREATE INDEX idx_txn_account ON Transactions(AccountID);

-- Investments
CREATE TABLE Investments (
  InvestmentID INT PRIMARY KEY AUTO_INCREMENT,
  Symbol VARCHAR(20) NOT NULL,
  Name VARCHAR(120) NOT NULL
);
CREATE UNIQUE INDEX ux_investments_symbol ON Investments(Symbol);

CREATE TABLE InvestmentTrades (
  TradeID INT PRIMARY KEY AUTO_INCREMENT,
  InvestmentID INT NOT NULL,
  AccountID INT NOT NULL,
  TradeDate DATE NOT NULL,
  Side ENUM('BUY','SELL') NOT NULL,
  Units DECIMAL(14,4) NOT NULL,
  Price DECIMAL(14,4) NOT NULL,
  Fees DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT fk_trades_investment FOREIGN KEY (InvestmentID) REFERENCES Investments(InvestmentID),
  CONSTRAINT fk_trades_account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
CREATE INDEX idx_trades_date ON InvestmentTrades(TradeDate);

CREATE TABLE InvestmentPrices (
  PriceID INT PRIMARY KEY AUTO_INCREMENT,
  InvestmentID INT NOT NULL,
  PriceDate DATE NOT NULL,
  ClosePrice DECIMAL(14,4) NOT NULL,
  CONSTRAINT fk_prices_investment FOREIGN KEY (InvestmentID) REFERENCES Investments(InvestmentID),
  CONSTRAINT ux_price_unique UNIQUE (InvestmentID, PriceDate)
);
CREATE INDEX idx_prices_latest ON InvestmentPrices(InvestmentID, PriceDate DESC);

-- Debts
CREATE TABLE Debts (
  DebtID INT PRIMARY KEY AUTO_INCREMENT,
  AccountID INT NOT NULL,
  CreditorName VARCHAR(120) NOT NULL,
  Principal DECIMAL(14,2) NOT NULL,
  InterestRate DECIMAL(6,3) NOT NULL, -- APR %
  StartDate DATE NOT NULL,
  DueDate DATE NULL,
  MinPayment DECIMAL(14,2) DEFAULT 0.00,
  CONSTRAINT fk_debts_account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE DebtPayments (
  PaymentID INT PRIMARY KEY AUTO_INCREMENT,
  DebtID INT NOT NULL,
  TransactionID INT NOT NULL,
  CONSTRAINT fk_dp_debt FOREIGN KEY (DebtID) REFERENCES Debts(DebtID),
  CONSTRAINT fk_dp_txn FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);
