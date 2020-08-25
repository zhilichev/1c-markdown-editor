CLS

@ECHO Building configuration...
@ECHO OFF

:: Включение режима расширенной обработки команд
SetLocal EnableExtensions

:: Получение каталога репозитория. Для этого файл build.cmd должен находиться в корне репозитория
SET RepositoryPath=%CD%

:: Определение имени файла журнала для билда
SET LogFile="%RepositoryPath%\build.log"

:: Определение имени файла с настройками окружения
SET EnvConfig="%RepositoryPath%\build.env"

:CHECK_ENVIRONMENT
IF NOT EXIST %EnvConfig%. (
    @ECHO %date% %time:~-11,8%   File %EnvConfig% not found >> %LogFile%
    GOTO CREATE_ENV_FILE
) ELSE (
    :: Загрузка настроек окружения из файла:
    ::  - PlatformExec - Полный путь к исполняемому файлу 1cv8.exe
    ::  - DatabaseType - Каталог базы данных
    ::  - Database - Каталог базы данных
    FOR /F "usebackq tokens=1,2 delims==" %%a IN (%EnvConfig%) DO SET %%a="%%b"
)

:: Каталог исходников конфигурации внутри репозитория
SET SourcePath="%RepositoryPath%\src\config"

:: Файл лога журнала
SET DumpFile="%RepositoryPath%\build.log"

:: Запуск загрузки конфигурации из файлов
%PlatformExec% DESIGNER /S%Database% /LoadConfigFromFiles %SourcePath% /UpdateDBCfg -Dynamic- -WarningsAsErrors /DumpResult %DumpFile%

@ECHO Configuration build completed. See %DumpFile% for results
@ECHO Starting 1C:Enterprise Designer %PlatformExec%

:: Запуск Конфигуратора
START "" %PlatformExec% DESIGNER /S%Database% /LEN

GOTO:EOF

:: ////////////////////////////////////////////////////////////////////////////////
:: Процедура создания файла build.env
:CREATE_ENV_FILE
@ECHO Can't find environment config file. Please, fill the following details.

:: ////////////////////////////////////////////////////////////////////////////////
:: Установка пути к файлу 1cv8.exe
:PLATFORM_EXEC_PATH
SET /P PlatformExec="Enter 1cv8.exe full path (without 1cv8.exe at the end) or Q for exit: "

:: Проверка варианта с выходом из программы
IF /I "%DatabaseType%"=="Q" EXIT

:: Проверка символа разделителя путей в конце. Если нету, добавляется
SET TempSubstring=%PlatformExec:~-1%
IF %TempSubstring% NEQ "\" (
    SET PlatformExec=%PlatformExec%\
)

:: Добавление имени исполняемого файла 1cv8.exe
SET PlatformExec=%PlatformExec%1cv8.exe

:: Проверка сущестования полного пути к файлу 1cv8.exe
IF NOT EXIST "%PlatformExec%". (
    @ECHO Could not find file 1cv8.exe at specified path. Please, retry.
    GOTO PLATFORM_EXEC_PATH
)

:: ////////////////////////////////////////////////////////////////////////////////
:: Запрос типа информационной базы: F - файловая, S - серверная
:DATABASE_TYPE

SET /P DatabaseType="Enter database type: F - file, S - server, or Q for exit: "

:: Проверка варианта с выходом из программы
IF /I "%DatabaseType%"=="Q" EXIT

IF /I "%DatabaseType%"=="S" SET DatabaseType=Server
IF /I "%DatabaseType%"=="F" SET DatabaseType=File

IF NOT DEFINED DatabaseType (
    @ECHO Database type specified incorrectly. Please, retry.
    GOTO DATABASE_TYPE    
)

:: ////////////////////////////////////////////////////////////////////////////////
:: Запрос пути к информационной базе в зависимости от типа ИБ
IF "%DatabaseType%"=="Server" (
    SET /P Database="Enter build database path in format "Server\Database": "    
) ELSE (
    SET /P Database="Enter build database path (without end slash): "
)

@ECHO PlatformExec=%PlatformExec% > %EnvConfig%
@ECHO DatabaseType=%DatabaseType% >> %EnvConfig%
@ECHO Database=%Database% >> %EnvConfig%

:: Возврат к процедуре проверки наличия файла build.env
:: GOTO CHECK_ENVIRONMENT