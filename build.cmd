@ECHO Building configuration...
@ECHO OFF

REM Каталог исполняемого файла 1cv8.exe
SET PlatformExec="C:\Program Files\1cv8\8.3.11.3034\bin\1cv8.exe"

REM Получение текущего каталога репозитория
SET RepositoryPath=%CD%

REM Каталог исходников конфигурации внутри репозитория
SET SourcePath="%RepositoryPath%\src\config"

REM Адрес информационной базы
SET Database="dev-1c-07:3541\07_zhilichev_gitflow"

REM Файл лога журнала
SET DumpFile="%RepositoryPath%\build.log"

REM Запуск загрузки конфигурации из файлов
%PlatformExec% DESIGNER /S%Database% /LoadConfigFromFiles %SourcePath% /UpdateDBCfg -Dynamic- -WarningsAsErrors /DumpResult %DumpFile%

@ECHO Configuration build completed. See %DumpFile% for results
@ECHO Starting 1C:Enterprise Designer

REM Запуск Конфигуратора
START "" %PlatformExec% DESIGNER /S%Database% /LEN