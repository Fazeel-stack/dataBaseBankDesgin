create procedure Pr_C_addCustomer
@C_FirstName varchar(30),
@C_LastName varchar(30) ='Unknown',
@C_Cnic char(15),
@C_PhoneNumber char(11)='Unknown',
@C_Gmail varchar(50) ='Unknown@gmail.com',
@C_TaxFiler bit =0,
@CreatedCustomerId bigint=null output
as 
begin
begin try
if exists(select 1 from C_CUSTOMERS where C_Cnic=@C_Cnic)
begin 
print 'A customer with identical Cnic already exists ; ; Pr_C_addCustomer';
return;
end
insert into C_CUSTOMERS(C_FirstName,C_LastName,C_Cnic,C_PhoneNumber,C_Gmail,C_TaxFiler)
values(@C_FirstName,@C_LastName,@C_Cnic,@C_PhoneNumber,@C_Gmail,@C_TaxFiler)

set @CreatedCustomerId=SCOPE_IDENTITY();
if @CreatedCustomerId is not null
begin
print 'Customer Added Successfully Id : '+ cast(@CreatedCustomerId as varchar(20))
end
end try 
begin catch
print 'Customer Adding Failed ,, Pr_C_addCustomer';
end catch
end







create procedure Pr_A_addAccount
@C_CustomerId bigint,
@B_BranchId int,
@A_AccountType varchar(15)='Current',
@CreatedAccountId bigint=null output
as
begin
begin try
if not exists(select 1 from B_BRANCHES where B_BranchId=@B_BranchId) or not exists (select 1 from C_CUSTOMERS where C_CustomerId=@C_CustomerId)
begin
 print 'Branch or cusotmer does not exist,,Pr_A_addAccount'
 return;
end
declare @accountno varchar(30)
set @accountno ='PK-'+cast(@B_BranchId as varchar)+'-'+cast(year(getdate()) as varchar)+'-'+cast(@C_CustomerId as varchar);

insert into A_ACCOUNTS(C_CustomerId,B_BranchId,A_AccountType,A_AccountNumber)
values(@C_CustomerId,@B_BranchId,@A_AccountType,@accountno)


set @CreatedAccountId=SCOPE_IDENTITY();
if @CreatedAccountId is not null
begin
print 'Account added successfully : '+@accountno;
end
end try
begin catch 
print 'Account adding Failed ;; Pr_A_addAccount'
end catch
end








create procedure Pr_C_A_createCustomerAndAccount
@C_FirstName varchar(30),
@C_LastName varchar(30) ='Unknown',
@C_Cnic char(15),
@C_PhoneNumber char(11)='Unknown',
@C_Gmail varchar(50) ='Unknown@gmail.com',
@C_TaxFiler bit =0,
@B_BranchId int,
@A_AccountType varchar(15)='Current'
as 
begin
begin try 
begin transaction
declare @customerid bigint =null
declare @accountid bigint =null

exec Pr_C_addCustomer @C_FirstName,@C_LastName,@C_Cnic,@C_PhoneNumber,@C_Gmail,@C_TaxFiler,@customerid output
if @customerid is null
begin
rollback transaction
print 'Customer Creation Failed undoing changes ; ; Pr_C_A_createCustomerAndAccount'

return;
end

exec Pr_A_addAccount @customerid,@B_BranchId,@A_AccountType,@accountid output
if @accountid is null
begin
rollback transaction;
print 'Account Creation Failed undoing changes ; ; Pr_C_A_createCustomerAndAccount'
return;
end
else
begin
commit transaction;
print 'Creation of Customer and Account Succesfull'
end
end try
begin catch
if @@trancount > 0 rollback transaction;
print 'Procedure Failed ; ; Pr_C_A_createCustomerAndAccount'
end catch
end


create procedure Pr_T_makeWithdraw
@A_AccountNumber varchar(30),
@T_Amount decimal(20,2)=0.00,
@T_ReferenceNote varchar(255)='a'
as 
begin
declare @accountid bigint =null;
declare @accountBalance decimal(20,2) =0.00;

begin try
select @accountid=A_AccountId,@accountBalance=A_Balance from A_ACCOUNTS where A_AccountNumber=@A_AccountNumber

if @accountid is null
begin
print 'Account id not found for'+@A_AccountNumber +';; Pr_T_makeWithdraw'
return;
end
if @T_Amount>@accountBalance
begin
print 'Insufficint balance' +cast(@accountBalance as varchar)+'for'+ @A_AccountNumber+ ';; Pr_T_makeWithdraw'
return;
end
begin transaction
update A_ACCOUNTS
set A_Balance=@accountBalance-@T_Amount where A_AccountId=@accountid;

insert into T_Transactions(A_AccountId,T_ReferenceNote,T_TransactionDate,T_TransactionType,T_Amount)
values(@accountid,@T_ReferenceNote,getdate(),'Withdrawal',@T_Amount);

commit transaction
print 'WithDraw Successful new balance : '+cast(@accountBalance-@T_Amount as varchar)
end try
begin catch
if @@trancount > 0 rollback transaction;
print 'Procedure Failed undoing changes;; Pr_T_makeWithdraw'
end catch
end


create procedure Pr_T_makeDeposit
@A_AccountNumber varchar(30),
@T_Amount decimal(20,2)=0.00,
@T_ReferenceNote varchar(255) ='a'
as 
begin
declare @accountid bigint =null;
declare @accountBalance decimal(20,2) =0.00;

begin try
select @accountid=A_AccountId,@accountBalance=A_Balance from A_ACCOUNTS where A_AccountNumber=@A_AccountNumber

if @accountid is null
begin
print 'Account id not found for'+@A_AccountNumber +';; Pr_T_makeDeposit'
return;
end

begin transaction
update A_ACCOUNTS
set A_Balance=@accountBalance+@T_Amount where A_AccountId=@accountid;

insert into T_Transactions(A_AccountId,T_ReferenceNote,T_TransactionDate,T_TransactionType,T_Amount)
values(@accountid,@T_ReferenceNote,getdate(),'Deposit',@T_Amount);

commit transaction
print 'Deposit Successful new balance : '+cast(@accountBalance+@T_Amount as varchar)
end try
begin catch
if @@trancount > 0 rollback transaction;
print 'Procedure Failed undoing changes;; Pr_T_makeDeposit'
end catch
end



create procedure Pr_T_makeTransfer
@T_AccountNumberSource varchar(30),
@T_AccountNumberDestination varchar(30),
@T_Amount decimal(20,2) =0.00,
@T_ReferenceNote varchar(255) ='a'
as
begin
declare @accountsourceid bigint =null
declare @accountdestinationid bigint =null
declare @accountsourcebalance decimal(20,2) =0.00
declare @transactionidsoruce bigint=null
begin try
select @accountsourceid=A_AccountId,@accountsourcebalance=A_Balance from A_ACCOUNTS where A_AccountNumber=@T_AccountNumberSource
select @accountdestinationid=A_AccountId from A_ACCOUNTS where A_AccountNumber=@T_AccountNumberDestination

if @accountdestinationid is null
begin
print 'Account Destiation Id not found for '+@T_AccountNumberDestination +' ; ;Pr_T_makeTransfer'
return;
end

if @accountsourceid is null
begin
print 'Account Source Id not found for '+@T_AccountNumberSource +' ; ;Pr_T_makeTransfer '
return;
end

if @accountsourcebalance<@T_Amount
begin
print 'insufficient funds in  account '+@T_AccountNumberSource +' ; ;Pr_T_makeTransfer '
return;
end

begin transaction
update A_ACCOUNTS 
set  A_Balance=A_Balance+@T_Amount where A_AccountNumber=@T_AccountNumberDestination

update A_ACCOUNTS 
set  A_Balance=A_Balance-@T_Amount where A_AccountNumber=@T_AccountNumberSource


insert into T_Transactions(A_AccountId,A_AccountIdOpposing,T_ReferenceNote,T_TransactionDate,T_Amount,T_TransactionType)
values(@accountsourceid,@accountdestinationid,@T_ReferenceNote,getdate(),@T_Amount,'Transfer')
set @transactionidsoruce=SCOPE_IDENTITY();

insert into T_Transactions(A_AccountId,A_AccountIdOpposing,T_LinkSource,T_ReferenceNote,T_TransactionDate,T_Amount,T_TransactionType)
values(@accountdestinationid,@accountsourceid,@transactionidsoruce,@T_ReferenceNote,getdate(),@T_Amount,'Transfer')

commit transaction

print 'Transfer of Funds Successfull ;;  Pr_T_makeTransfer'
end try
begin catch
if @@trancount > 0 rollback transaction;
print 'Procdure Failed ;;  Pr_T_makeTransfer'
end catch
end



drop procedure if exists Pr_C_A_createCustomerAndAccount;
drop procedure if exists Pr_C_addCustomer;
drop procedure if exists Pr_A_addAccount;
drop procedure if exists Pr_T_makeWithdraw;
drop procedure if exists Pr_T_makeDeposit;
drop procedure if exists Pr_T_makeTransfer;
