@ECHO Building configuration...
@ECHO OFF

REM Каталог исполняемого файла 1cv8.exe
SET PlatformExec="C:\Program Files\1cv8\8.3.11.3034\bin\1cv8.exe"

REM Получение текущего каталога репозитория
SET RepositoryPath=%CD%

REM Каталог исходников конфигурации внутри репозитория
SET SourcePath="%RepositoryPath%\src\config"

REM Адрес информационной базы
SET Database="C:\home\1c-db\md-editor"

REM Файл лога журнала
SET DumpFile="%RepositoryPath%\build.log"

REM Запуск загрузки конфигурации из файлов
%PlatformExec% DESIGNER /F%Database% /LoadConfigFromFiles %SourcePath% /UpdateDBCfg -Dynamic- -WarningsAsErrors /DumpResult %DumpFile%

@ECHO Configuration build completed. See %DumpFile% for results
@ECHO Starting 1C:Enterprise Designer

REM Запуск Конфигуратора
START "" %PlatformExec% DESIGNER /F%Database% /LEN
