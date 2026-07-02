
create database Bank;
use Bank;



create table B_BRANCHES(
B_BranchId int primary key identity(1,1),
B_BranchCode varchar(10) unique not null,
B_BranchName varchar(100) not null,
B_City varchar(30) not null default 'Lahore'

)

create table C_CUSTOMERS(
C_CustomerId bigint primary key identity(1,1),
C_FirstName varchar(30) not null,
C_LastName varchar(30) default 'Unknown',
C_Cnic char(15) unique not null,
C_PhoneNumber char(11) default 'Unknown',
C_Gmail varchar(50) default 'Unknown@gmail.com',
C_TaxFiler bit default 0,
C_CreatedAt datetime default getdate(),
constraint chk_gmail check(C_Gmail like '%@gmail.com'),
)

create table A_ACCOUNTS(
A_AccountId bigint primary key identity(1,1),
C_CustomerId bigint not null,
B_BranchId int not null,
A_AccountNumber varchar(30) unique not null,
A_AccountType varchar(15) check(A_AccountType in ('Savings','Current')),
A_Balance decimal(20,2) not null default 0.00,
A_Status varchar(10) default 'Active' check (A_Status in('Active','Dormant','Closed')),

constraint chk_balance check(A_Balance>=0),
foreign key (C_CustomerId) references C_Customers(C_CustomerId),
foreign key (B_BranchId) references B_Branches(B_BranchId),
)

create table  T_Transactions (
    T_TransactionId bigint primary key identity(1,1),
    T_LinkSource bigint null,
    A_AccountId bigint not null,
    A_AccountIdOpposing bigint null,
    T_TransactionType varchar(20) check (T_TransactionType in ('Deposit', 'Withdrawal', 'Transfer')),
    T_Amount decimal(20,2) not null,
    T_TransactionDate datetime default getdate(),
    T_ReferenceNote varchar(255) not null,
    
    foreign key (A_AccountIdOpposing) REFERENCES A_Accounts(A_AccountId),
    foreign key (A_AccountId) REFERENCES A_Accounts(A_AccountId),
    constraint chk_accounts check(A_AccountId!=A_AccountIdOpposing),
);



CREATE TABLE E_EMPLOYEES (
    E_EmployeeId int primary key identity(1,1),
    E_FirstName varchar(30) not null,
    E_LastName varchar(30) default 'Unknown',
    E_Role varchar(20) check (E_Role in ('Admin', 'Teller', 'Manager')),
    B_BranchId int not null,
    foreign key (B_BranchId) references B_BRANCHES(B_BranchId)
);


create table AL_AUDITS_LOGS(
    AL_AuditId bigint primary key identity(1,1),
    AL_TableName varchar(50),
    AL_RecordId bigint,
    AL_Operation varchar(10),
    AL_OldValue decimal(20,2),
    AL_NewValue decimal(20,2),
    AL_ChangedByName varchar(50) not null default SYSTEM_USER,
    AL_ChangedAt datetime default getdate(),
)


drop table if exists T_Transactions;
drop table if exists AL_AUDITS_LOGS;
drop table if exists A_ACCOUNTS;
drop table if exists C_CUSTOMERS;
drop table if exists E_EMPLOYEES;
drop table if exists B_BRANCHES;