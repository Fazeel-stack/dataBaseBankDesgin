



insert into B_BRANCHES (B_BranchName, B_BranchCode, B_City) values 
('Main Gulberg', 'GUL-001', 'Lahore'),
('DHA Ph 6', 'DHA-006', 'Lahore'),
('I-8 Isb', 'ISB-008', 'Islamabad'),
('Clifton Khi', 'KHI-010', 'Karachi');

select * from B_BRANCHES;



exec Pr_C_A_createCustomerAndAccount 'Ahmed','Ali','35201-1111111-1','03001112223','ahmed@gmail.com',1,1,'Current'


exec Pr_C_A_createCustomerAndAccount 'Fatima',default,'35201-2222222-2',default,default,0,2,'Savings'


exec Pr_C_A_createCustomerAndAccount 'Zohaib','Hassan','35201-3333333-3',default,default,0,3,'Current'


exec Pr_C_A_createCustomerAndAccount 'DuplicateCnic',default,'35201-1111111-1',default,default,0,1,'Current'


exec Pr_C_A_createCustomerAndAccount 'NoBranch',default,'35201-9999999-9',default,default,0,999,'Current'

select C.C_FirstName, A.A_AccountNumber, B.B_BranchName
from C_CUSTOMERS C
join A_ACCOUNTS A on C.C_CustomerId = A.C_CustomerId
join B_BRANCHES B on A.B_BranchId = B.B_BranchId;


select * from C_CUSTOMERS;
select * from A_ACCOUNTS;






