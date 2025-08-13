-- procedures.sql

DELIMITER $$

-- Monthly budget report for given year & month
CREATE PROCEDURE sp_monthly_budget_report(IN pYear INT, IN pMonth INT)
BEGIN
  SELECT * FROM v_budget_vs_spend
  WHERE Year = pYear AND Month = pMonth
  ORDER BY CategoryName;
END$$

-- Simple savings forecast: average monthly savings over last N months * monthsAhead
CREATE PROCEDURE sp_forecast_savings(IN monthsLookback INT, IN monthsAhead INT)
BEGIN
  -- compute average savings
  SELECT
    ROUND(AVG(NetSavings),2) AS AvgMonthlySavings,
    monthsAhead AS MonthsAhead,
    ROUND(AVG(NetSavings) * monthsAhead,2) AS ProjectedSavings
  FROM v_monthly_summary
  ORDER BY Year DESC, Month DESC
  LIMIT monthsLookback;
END$$

DELIMITER ;
