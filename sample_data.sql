-- sample_data.sql
-- Minimal but realistic sample data

INSERT INTO Categories (CategoryName, Type) VALUES
 ('Salary','Income'),
 ('Bonus','Income'),
 ('Freelance','Income'),
 ('Food','Expense'),
 ('Groceries','Expense'),
 ('Transport','Expense'),
 ('Rent','Expense'),
 ('Utilities','Expense'),
 ('Entertainment','Expense'),
 ('Investing','Expense');

-- Subcategory example
INSERT INTO Categories (CategoryName, Type, ParentCategoryID)
SELECT 'Dining Out','Expense', CategoryID FROM Categories WHERE CategoryName='Food' AND Type='Expense';

INSERT INTO Accounts (AccountName, AccountType, CurrentBalance, OpenDate) VALUES
 ('Cash Wallet','Cash', 500.00, CURRENT_DATE),
 ('HDFC Checking','Bank', 25000.00, CURRENT_DATE),
 ('SBI Credit','CreditCard', -5500.00, CURRENT_DATE),
 ('Groww Investment','Investment', 0.00, CURRENT_DATE),
 ('Home Loan','Loan', -1200000.00, CURRENT_DATE);

-- Budgets (for 2025 Aug/Sept)
INSERT INTO Budgets (CategoryID, Year, Month, Amount)
SELECT CategoryID, 2025, 8, 12000.00 FROM Categories WHERE CategoryName IN ('Groceries','Transport','Entertainment','Utilities','Dining Out') AND Type='Expense';
INSERT INTO Budgets (CategoryID, Year, Month, Amount)
SELECT CategoryID, 2025, 9, 12000.00 FROM Categories WHERE CategoryName IN ('Groceries','Transport','Entertainment','Utilities','Dining Out') AND Type='Expense';

-- Transactions (Income in Bank; Expenses from various accounts)
-- August 2025
INSERT INTO Transactions (AccountID, CategoryID, Amount, TxnDate, Notes)
SELECT a.AccountID, c.CategoryID, 120000.00, '2025-08-01', 'August Salary'
FROM Accounts a CROSS JOIN Categories c
WHERE a.AccountName='HDFC Checking' AND c.CategoryName='Salary' AND c.Type='Income';

INSERT INTO Transactions (AccountID, CategoryID, Amount, TxnDate, Notes)
SELECT a.AccountID, c.CategoryID, 3000.00, '2025-08-03', 'Groceries - BigBasket'
FROM Accounts a CROSS JOIN Categories c
WHERE a.AccountName='HDFC Checking' AND c.CategoryName='Groceries' AND c.Type='Expense';

INSERT INTO Transactions (AccountID, CategoryID, Amount, TxnDate, Notes)
SELECT a.AccountID, c.CategoryID, 400.00, '2025-08-04', 'Metro ride'
FROM Accounts a CROSS JOIN Categories c
WHERE a.AccountName='Cash Wallet' AND c.CategoryName='Transport' AND c.Type='Expense';

INSERT INTO Transactions (AccountID, CategoryID, Amount, TxnDate, Notes)
SELECT a.AccountID, c.CategoryID, 18000.00, '2025-08-05', 'Rent August'
FROM Accounts a CROSS JOIN Categories c
WHERE a.AccountName='HDFC Checking' AND c.CategoryName='Rent' AND c.Type='Expense';

INSERT INTO Transactions (AccountID, CategoryID, Amount, TxnDate, Notes)
SELECT a.AccountID, c.CategoryID, 2200.00, '2025-08-06', 'Electricity bill'
FROM Accounts a CROSS JOIN Categories c
WHERE a.AccountName='HDFC Checking' AND c.CategoryName='Utilities' AND c.Type='Expense';

-- Investment: Buy 10 units of ABC at 1000, fee 20
INSERT INTO Investments (Symbol, Name) VALUES ('ABC', 'ABC Industries Ltd.');
INSERT INTO InvestmentTrades (InvestmentID, AccountID, TradeDate, Side, Units, Price, Fees)
SELECT i.InvestmentID, a.AccountID, '2025-08-07', 'BUY', 10.0000, 1000.0000, 20.00
FROM Investments i CROSS JOIN Accounts a
WHERE i.Symbol='ABC' AND a.AccountName='Groww Investment';
INSERT INTO InvestmentPrices (InvestmentID, PriceDate, ClosePrice)
SELECT InvestmentID, '2025-08-12', 1045.50 FROM Investments WHERE Symbol='ABC';

-- Debt & payment (credit card payment logged as Transaction then linked)
INSERT INTO Debts (AccountID, CreditorName, Principal, InterestRate, StartDate, DueDate, MinPayment)
SELECT a.AccountID, 'SBI Card', 5500.00, 36.000, '2025-07-15', '2025-09-10', 1000.00
FROM Accounts a WHERE a.AccountName='SBI Credit';

-- Payment: 2000 to SBI Card from Bank
INSERT INTO Transactions (AccountID, CategoryID, Amount, TxnDate, Notes)
SELECT (SELECT AccountID FROM Accounts WHERE AccountName='SBI Credit'),
       (SELECT CategoryID FROM Categories WHERE CategoryName='Utilities' AND Type='Expense'),
       2000.00, '2025-08-08', 'Credit card payment (categorized as Utilities for demo)';
-- Link the payment to the debt
INSERT INTO DebtPayments (DebtID, TransactionID)
SELECT d.DebtID, t.TransactionID
FROM Debts d, Transactions t
WHERE d.CreditorName='SBI Card'
  AND t.Notes LIKE 'Credit card payment%'
ORDER BY t.TransactionID DESC LIMIT 1;
