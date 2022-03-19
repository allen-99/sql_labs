create table Departments
(
    `Department ID`   int not null,
    `Department name` varchar(60) not null,
    primary key (`Department ID`)
);

 insert into Departments (`Department ID`, `Department name`) value (128,'Отдел проектирования');
 insert into Departments (`Department ID`, `Department name`) value (42,'Финансовый отдел');

create table if not exists Workers
(
    ID              int         not null primary key,
    FIO             varchar(50) not null,
    Position        varchar(30) not null,
    `Department ID` int         not null,
    foreign key (`Department ID`) references Departments (`Department ID`)
);

create table Qualifications
(
    ID   int not null,
    Qualification varchar(60) not null,
    primary key (ID,Qualification)
);
 insert into Qualifications (ID, Qualification)
 values (7513, 'Java'),
        (7513, 'C'),
        (9842 , 'DB2'),
        (6651, 'Java'),
        (6651 , 'VB'),
        (9006 ,'Linux'),
        (9006, 'Windows');

 insert into Workers (ID, FIO, Position, `Department ID`)
 values (7513, 'Иванов Иван Иванович','Программист',128),
        (9842,'Сергеева Светлана Сергеевна','Админимстратор БД',42),
        (6651,'Петров Петр Петрович','Программист',128),
        (9006,'Николаев Николай Николаевич','Системный администатор', 128);

insert into Workers (ID, FIO, Position, `Department ID`)
 values (7512, 'Иванов Борис Борисович','Программист', 42),
        (9846,'Сидорова Татьяна Сергеевна','Программист',42),
        (6653,'Сергеев Алексей Петрович','Системный администатор',128),
        (9045,'Понкратов Николай Иванович','Админимстратор БД', 128);

 insert into Qualifications (ID, Qualification)
 values (7512, 'Java'),
        (9846, 'C'),
        (9846 , 'DB2'),
        (6653, 'Java'),
        (6653 , 'VB'),
        (9045 ,'Linux'),
        (7512, 'Windows');

select * from Workers;
select * from Qualifications;
select * from Departments;

# 1 - ID и FIO всех программистов, чей ID меньше среднего
select ID, FIO
from Workers
where ID < (select avg(ID) from Workers)
  and Position = 'Программист';

# 2 - ID, FIO, Position всех программистов, чья квалификация Java
select Workers.ID, FIO, Position
from Workers,
     (select ID from Qualifications where Qualification = 'Java' group by ID) as QI
where Position = 'Программист'
  and QI.ID = Workers.ID;

# 3 - FIO, Position, Department ID рабочих из Отдела проектирования
select FIO, Position, `Department ID`
from Workers
group by Workers.ID
having `Department ID` =
       (select `Department ID`
        from Departments
        where Departments.`Department name` = 'Отдел проектирования');

#4 - Количество программистов в каждом отделе
select `Department ID`,
       (select count(Position) from Workers where Position = 'Программист') as 'Number of programmers'
from Departments;

# 5 - Все программисты из департамента 128 крутые
update Workers
set Position = 'Крутой Программист'
where `Department ID` = 128
  and Position = 'Программист';
# select * from Workers;

# 6 - Представление на основе запроса 1
create view select1_v
    (ID, FIO) as
select ID, FIO
from Workers
where ID < (select avg(ID) from Workers)
  and Position = 'Программист';

# 7 - Представление на основе запроса 2 (после update значения запроса могут быть изменены)
create view select2_v
    (ID, FIO, Position) as
select Workers.ID, FIO, Position
from Workers,
     (select ID from Qualifications where Qualification = 'Java' group by ID) as QI
where Position = 'Программист'
  and QI.ID = Workers.ID;

# 8 - Создание таблицы Новые отделы (NewDepartment)
create table NewDepartments
(
    `Department ID`   int         not null,
    `Department name` varchar(60) not null,
    primary key (`Department ID`)
);

# 9 - Добавление двух отделов в таблицу NewDepartment
insert into NewDepartments
    (`Department ID`, `Department name`) value (882, 'Отдел разработки');
insert into NewDepartments
    (`Department ID`, `Department name`) value (123, 'Отдел правового регулирования');

# 10 - Предаствление на объединение таблиц NewDepartment и Departments
create view UnionDepartments as
select distinct *
from Departments
union
select distinct *
from NewDepartments;

# Добавление одного столбца в таблицу Qualifications
alter table Qualifications add column WorkExperience int not null after Qualification;
select * from Qualifications;

update Qualifications
    set Qualifications.WorkExperience = Qualifications.ID * 1024;


# 1 - В зависимости от опыта работы назначается уровень квалификации
select ID, Qualification, WorkExperience,
    case
        when WorkExperience <= 7000000 then 'Junior'
        when WorkExperience <= 10000000 then 'Middle'
        else 'Senior'
    end RangeOfQualification
from Qualifications;

#2 - В зависимоти от квалификации назначается новогодний бонус
select ID, Qualification, WorkExperience,
       case Qualification
            when 'Java' then '30%'
            when 'VB' then '60%'
            when 'Windows' then '90%'
            else '50%'
    end NewYearBonusPercent
from Qualifications;