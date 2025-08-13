-- views.sql

-- Monthly income/expense/savings summary
CREATE OR REPLACE VIEW v_monthly_summary AS
SELECT
  YEAR(t.TxnDate) AS Year,
  MONTH(t.TxnDate) AS Month,
  SUM(CASE WHEN c.Type='Income' THEN t.Amount ELSE 0 END) AS TotalIncome,
  SUM(CASE WHEN c.Type='Expense' THEN t.Amount ELSE 0 END) AS TotalExpense,
  SUM(CASE WHEN c.Type='Income' THEN t.Amount ELSE -t.Amount END) AS NetSavings
FROM Transactions t
JOIN Categories c ON c.CategoryID = t.CategoryID
GROUP BY YEAR(t.TxnDate), MONTH(t.TxnDate);

-- Budget vs Spend per category
CREATE OR REPLACE VIEW v_budget_vs_spend AS
SELECT
  b.Year, b.Month, c.CategoryName,
  b.Amount AS Budget,
  IFNULL(SUM(CASE WHEN c.Type='Expense' THEN t.Amount ELSE 0 END),0) AS Spent,
  (b.Amount - IFNULL(SUM(CASE WHEN c.Type='Expense' THEN t.Amount ELSE 0 END),0)) AS Remaining
FROM Budgets b
JOIN Categories c ON c.CategoryID = b.CategoryID
LEFT JOIN Transactions t
  ON t.CategoryID = b.CategoryID
 AND YEAR(t.TxnDate) = b.Year
 AND MONTH(t.TxnDate) = b.Month
GROUP BY b.Year, b.Month, c.CategoryName, b.Amount;

-- Holdings view (units & cost basis from trades)
CREATE OR REPLACE VIEW v_investment_holdings AS
SELECT
  i.InvestmentID,
  i.Symbol,
  i.Name,
  SUM(CASE WHEN tr.Side='BUY' THEN tr.Units ELSE -tr.Units END) AS NetUnits,
  SUM(CASE WHEN tr.Side='BUY' THEN (tr.Units*tr.Price + tr.Fees)
           ELSE -(tr.Units*tr.Price - tr.Fees) END) AS NetCashFlow
FROM Investments i
LEFT JOIN InvestmentTrades tr ON tr.InvestmentID = i.InvestmentID
GROUP BY i.InvestmentID, i.Symbol, i.Name;

-- Latest price per investment
CREATE OR REPLACE VIEW v_investment_latest_price AS
SELECT p.InvestmentID, p.ClosePrice, p.PriceDate
FROM InvestmentPrices p
JOIN (
  SELECT InvestmentID, MAX(PriceDate) AS MaxDate
  FROM InvestmentPrices
  GROUP BY InvestmentID
) m ON p.InvestmentID=m.InvestmentID AND p.PriceDate=m.MaxDate;

-- P&L using holdings and latest price
CREATE OR REPLACE VIEW v_investment_pnl AS
SELECT
  h.InvestmentID, i.Symbol, i.Name,
  h.NetUnits,
  lp.ClosePrice AS LastPrice,
  ROUND(h.NetUnits * lp.ClosePrice, 2) AS MarketValue,
  ROUND(-h.NetCashFlow, 2) AS CostBasis, -- buys are positive cash-out
  ROUND(h.NetUnits * lp.ClosePrice + h.NetCashFlow, 2) AS UnrealizedPnL
FROM v_investment_holdings h
JOIN Investments i ON i.InvestmentID=h.InvestmentID
JOIN v_investment_latest_price lp ON lp.InvestmentID=h.InvestmentID;
