select 'drop '||object_type||' '|| object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';'  from user_objects

ALTER USER HR ACCOUNT UNLOCK IDENTIFIED BY password;

SELECT 'DROP TABLE "' || TABLE_NAME || '" CASCADE CONSTRAINTS;' FROM user_tables;

select * from invoices;

DROP TABLE "REGIONS" CASCADE CONSTRAINTS;
DROP TABLE "LOCATIONS" CASCADE CONSTRAINTS;
DROP TABLE "DEPARTMENTS" CASCADE CONSTRAINTS;
DROP TABLE "JOBS" CASCADE CONSTRAINTS;
DROP TABLE "EMPLOYEES" CASCADE CONSTRAINTS;
DROP TABLE "JOB_HISTORY" CASCADE CONSTRAINTS;
DROP TABLE "CUSTOMERS" CASCADE CONSTRAINTS;
DROP TABLE "REGION" CASCADE CONSTRAINTS;
DROP TABLE "TERRITORIES" CASCADE CONSTRAINTS;
DROP TABLE "CATEGORIES" CASCADE CONSTRAINTS;
DROP TABLE "SUPPLIERS" CASCADE CONSTRAINTS;
DROP TABLE "PRODUCTS" CASCADE CONSTRAINTS;
DROP TABLE "SHIPPERS" CASCADE CONSTRAINTS;
DROP TABLE "CUSTOMERDEMOGRAPHICS" CASCADE CONSTRAINTS;
DROP TABLE "CUSTOMERCUSTOMERDEMO" CASCADE CONSTRAINTS;
DROP TABLE "COUNTRIES" CASCADE CONSTRAINTS;