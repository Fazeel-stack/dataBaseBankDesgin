


 --deposit money into ahmed
exec Pr_T_makeDeposit 'PK-1-2026-1', 10000.00, 'Initial Deposit';

 --deposit money into fatima
exec Pr_T_makeDeposit 'PK-2-2026-2', 5000.00, 'Salary Credit';

-- withdraw from Ahmed
exec Pr_T_makeWithdraw 'PK-1-2026-1', 2000.00, 'ATM Cash Out';

-- transfer from Ahmed to fatima
exec Pr_T_makeTransfer 'PK-1-2026-1', 'PK-2-2026-2', 3000.00, 'Rent Payment';

-- fail test insufficient funds ahmed has 5000 left
exec Pr_T_makeWithdraw 'PK-1-2026-1', 10000.00, 'More Than funds';


select A_AccountNumber, A_Balance, A_AccountType from A_ACCOUNTS;

select * from T_Transactions order by T_TransactionDate desc;