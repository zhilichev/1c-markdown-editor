@ECHO Building configuration...
@ECHO OFF

REM Получение каталога репозитория. Для этого файл build.cmd должен находиться в корне репозитория
SET RepositoryPath=%CD%

REM Определение имени файла журнала для билда
SET LogFile="%RepositoryPath%\build.log"

REM Определение имени файла с настройками окружения
SET EnvSettings="%RepositoryPath%\build.env"

:CHECK_ENVIRONMENT
IF NOT EXIST %EnvSettings%. (
    @ECHO %date% %time:~-11,8%   File %EnvSettings% not found >> %LogFile%
    GOTO CREATE_ENV_FILE
) ELSE (
    REM Загрузка настроек окружения из файла:
    REM  - PlatformExec - Полный путь к исполняемому файлу 1cv8.exe
    REM  - Database - Каталог базы данных
    FOR /F "usebackq tokens=1,2 delims==" %%a IN (%EnvSettings%) DO SET %%a="%%b"
)

REM Каталог исходников конфигурации внутри репозитория
SET SourcePath="%RepositoryPath%\src\config"

REM Файл лога журнала
SET DumpFile="%RepositoryPath%\build.log"

REM Запуск загрузки конфигурации из файлов
%PlatformExec% DESIGNER /F%Database% /LoadConfigFromFiles %SourcePath% /UpdateDBCfg -Dynamic- -WarningsAsErrors /DumpResult %DumpFile%

@ECHO Configuration build completed. See %DumpFile% for results
@ECHO Starting 1C:Enterprise Designer

REM Запуск Конфигуратора
START "" %PlatformExec% DESIGNER /F%Database% /LEN

GOTO:EOF

REM Процедура создания файла build.env
:CREATE_ENV_FILE
SET /P PlatformExec="Enter 1cv8.exe full path [with 1cv8.exe at end]: "
SET /P Database="Enter build database path [without end slash]: "

@ECHO PlatformExec=%PlatformExec% > %EnvSettings%
@ECHO Database=%Database% >> %EnvSettings%

REM Возврат к процедуре проверки наличия файла build.env
GOTO CHECK_ENVIRONMENT