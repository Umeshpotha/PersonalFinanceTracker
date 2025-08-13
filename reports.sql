-- reports.sql

-- 1) Monthly Summary
SELECT * FROM v_monthly_summary ORDER BY Year DESC, Month DESC;

-- 2) Budget vs Spend for current month (change as desired)
SET @y := YEAR(CURDATE()), @m := MONTH(CURDATE());
SELECT * FROM v_budget_vs_spend WHERE Year=@y AND Month=@m ORDER BY CategoryName;

-- 3) Top expense categories this month
SELECT c.CategoryName, SUM(t.Amount) AS Spent
FROM Transactions t
JOIN Categories c ON c.CategoryID=t.CategoryID
WHERE c.Type='Expense'
  AND YEAR(t.TxnDate)=@y AND MONTH(t.TxnDate)=@m
GROUP BY c.CategoryName
ORDER BY Spent DESC
LIMIT 10;

-- 4) Investment P&L (latest)
SELECT * FROM v_investment_pnl ORDER BY Symbol;

-- 5) Debt payments & outstanding (simple)
SELECT d.DebtID, d.CreditorName, d.Principal,
       IFNULL(SUM(t.Amount),0) AS PaymentsLogged,
       (d.Principal - IFNULL(SUM(t.Amount),0)) AS Outstanding
FROM Debts d
LEFT JOIN DebtPayments dp ON dp.DebtID=d.DebtID
LEFT JOIN Transactions t ON t.TransactionID=dp.TransactionID
GROUP BY d.DebtID, d.CreditorName, d.Principal
ORDER BY Outstanding DESC;
