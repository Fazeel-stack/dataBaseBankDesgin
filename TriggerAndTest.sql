create trigger Tr_A_AuditBalance
on A_ACCOUNTS
after update
as
begin

if update(A_Balance)
begin
insert into AL_AUDITS_LOGS (AL_TableName, AL_RecordId, AL_Operation, AL_OldValue, AL_NewValue, AL_ChangedByName)
select 'A_ACCOUNTS',i.A_AccountId,'UPDATE',cast(d.A_Balance as nvarchar(max)),cast(i.A_Balance as nvarchar(max)),SYSTEM_USER
from inserted i
join deleted d on i.A_AccountId = d.A_AccountId
where i.A_Balance != d.A_Balance;
end
end


select * from C_CUSTOMERS;
select * from A_ACCOUNTS;

update A_ACCOUNTS 
set A_Balance=1000000000 where C_CustomerId=1


select * from AL_AUDITS_LOGS


drop trigger Tr_A_AuditBalance