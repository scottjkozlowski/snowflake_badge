--Lists Databases accesible by current role irregardless of DB dropdown
show databases;

--Lists database schemas for a DB seelected in the worksheet dropdown menu
--If no dropdown is selected then all schemas for all dbs accessible
show schemas;

--If IN ACCOUNT is added then all accessible schemas in all accessible db are shown
show schemas in account;