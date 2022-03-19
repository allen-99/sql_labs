
# Добавление поля StartDate, обрзначающее дата поступления на работу (выбрано относительно специальности)
alter table Workers add column StartDate date after Position;
select * from Workers;
update Workers
    set Workers.StartDate = '2004-02-12';
update Workers
    set Workers.StartDate = '2014-02-11'
where Position = 'Крутой Программист';
update Workers
    set StartDate = '2019-12-11'
where Position = 'Системный администатор';
update Workers
    set StartDate = '2020-12-11'
where Position = 'Программист';
update Workers
    set StartDate = '2007-11-11'
where Position = 'Админимстратор БД';

# Удалить функцию для изменения
DROP FUNCTION Experience;
# 1 - Функция расчета стажа сотрудника, входные параметры - дата начало работы сотрудника
delimiter //
create function Experience(StartDate date)
    returns integer
deterministic
begin
    declare currdate date;
    declare diff integer;
    select SYSDATE() into currdate;
    select DATEDIFF(currdate, StartDate) into diff;
    select diff / 360 into diff;
    return diff;
end //

# вывод функции Experience
select FIO, Position, StartDate, Experience(StartDate) as 'Experience' from Workers;

# 2 - функция преобразование полного фио в фамилию с инициалами
delimiter //
create function FIO(yourfio varchar(100))
    returns varchar(100)
deterministic
begin
    declare aaa varchar(100);
    declare firstspace integer;
    declare secondspace integer;
    declare surname varchar(100);
    declare name varchar(100);
    declare otch varchar(100);

    if ((LENGTH(yourfio) - LENGTH(replace(yourfio, ' ', '')) + 1) = 3) then
        set aaa = yourfio;
    else
        set aaa = '#######';
        return aaa;
    end if;

    set firstspace = LOCATE(' ', yourfio);
    set secondspace = LOCATE(' ', yourfio, firstspace + 1);

    set surname = substring_index(yourfio, ' ', 1);


    set name = substring(yourfio, firstspace  + 1, 1);
    set name = concat(name, '.');

    set otch = substring(yourfio, secondspace  + 1, 1);
    set otch = concat(otch, '.');

    set aaa = concat_ws(' ', surname, name, otch);

    return aaa;
end //

# вызов функции 2
select FIO('Соколов Андрей Петрович');

# 3 - функция перевода номера телефона в нужный формат
delimiter //
create function telephoneNumberr(num varchar(100))
    returns varchar(100)
deterministic
begin
    declare lengthNumber integer;
    declare outputNumber varchar(100);
    declare number varchar(100);


    set number = replace(num,'-','');
    if (length(num) - length(number) > 3) then
        return NULL;
    end if;
    set outputNumber = '';

    set lengthNumber = length(number);
    if (lengthNumber < 7) then
        set outputNumber = number;
    end if;
    if (lengthNumber >= 7 and lengthNumber < 10) then
        set outputNumber = concat_ws('-', substring(number,1,3),
                                            substring(number,4,2),
                                            substring(number,6,2));
    end if;
    if (lengthNumber = 10) then
        set outputNumber = concat_ws('-', '8',
                                            substring(number,1,3),
                                            substring(number,4,3),
                                            substring(number,7,2),
                                            substring(number,9,2));

    end if;
    if (lengthNumber = 11) then
        set outputNumber = concat_ws('-', substring(number,1,1),
                                            substring(number,2,3),
                                            substring(number,5,3),
                                            substring(number,8,2),
                                            substring(number,10,2));
    end if;

    if (outputNumber = '') then
        return NULL;
    end if;
    return outputNumber;
end //


select telephoneNumberr('8908-123-45-67');

# 4 - по заданной квалификации (входной параметр), выводящая список
# сотрудников (ФИО и должность) с сортировкой по ФИО.
delimiter //
create procedure listOfWorkers(positionIN varchar(100))
begin
    select FIO, Position from Workers where Position = positionIN order by FIO;
end //

call listOfWorkers('Системный администатор');

# 5 - Процедура, по заданному номеру отдела (входной параметр), выводящая
# список сотрудников
delimiter //
create procedure listOfWorkers2(departmentID integer)
begin
    select ID, FIO(FIO),
           Position,
           StartDate,
           Experience(StartDate) as 'Experience (years)',
           `Department ID`
    from Workers
    where `Department ID` = departmentID;
end //

call listOfWorkers2(128);