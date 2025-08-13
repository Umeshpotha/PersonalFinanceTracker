-- triggers.sql
-- Maintain Accounts.CurrentBalance based on Transactions (simple net logic):
-- Income increases balance; Expense decreases balance.
-- We infer direction via Categories.Type

DELIMITER $$

CREATE TRIGGER trg_txn_after_insert
AFTER INSERT ON Transactions FOR EACH ROW
BEGIN
  DECLARE catType ENUM('Income','Expense');
  SELECT Type INTO catType FROM Categories WHERE CategoryID = NEW.CategoryID;
  IF catType='Income' THEN
    UPDATE Accounts SET CurrentBalance = CurrentBalance + NEW.Amount WHERE AccountID = NEW.AccountID;
  ELSE
    UPDATE Accounts SET CurrentBalance = CurrentBalance - NEW.Amount WHERE AccountID = NEW.AccountID;
  END IF;
END$$

CREATE TRIGGER trg_txn_after_update
AFTER UPDATE ON Transactions FOR EACH ROW
BEGIN
  DECLARE oldType ENUM('Income','Expense');
  DECLARE newType ENUM('Income','Expense');
  SELECT Type INTO oldType FROM Categories WHERE CategoryID = OLD.CategoryID;
  SELECT Type INTO newType FROM Categories WHERE CategoryID = NEW.CategoryID;

  -- Revert old
  IF oldType='Income' THEN
    UPDATE Accounts SET CurrentBalance = CurrentBalance - OLD.Amount WHERE AccountID = OLD.AccountID;
  ELSE
    UPDATE Accounts SET CurrentBalance = CurrentBalance + OLD.Amount WHERE AccountID = OLD.AccountID;
  END IF;

  -- Apply new
  IF newType='Income' THEN
    UPDATE Accounts SET CurrentBalance = CurrentBalance + NEW.Amount WHERE AccountID = NEW.AccountID;
  ELSE
    UPDATE Accounts SET CurrentBalance = CurrentBalance - NEW.Amount WHERE AccountID = NEW.AccountID;
  END IF;
END$$

CREATE TRIGGER trg_txn_after_delete
AFTER DELETE ON Transactions FOR EACH ROW
BEGIN
  DECLARE catType ENUM('Income','Expense');
  SELECT Type INTO catType FROM Categories WHERE CategoryID = OLD.CategoryID;
  IF catType='Income' THEN
    UPDATE Accounts SET CurrentBalance = CurrentBalance - OLD.Amount WHERE AccountID = OLD.AccountID;
  ELSE
    UPDATE Accounts SET CurrentBalance = CurrentBalance + OLD.Amount WHERE AccountID = OLD.AccountID;
  END IF;
END$$

DELIMITER ;
