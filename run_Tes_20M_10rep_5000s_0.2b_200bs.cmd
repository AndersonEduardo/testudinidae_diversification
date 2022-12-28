@echo off

:: DEFININDO AS VARIAVEIS
::numero de replicas:
set max_rep=7
::caminho relativo ate o arquivo pbdb_data_PyRate.py:
set pbd_path="pbdb_data_PyRate.py"
:: caminho relativo para a pasta MCMC logs:
set pyrate_mcmc_logs="pyrate_mcmc_logs"
:: arquivo da variavel para analise de correlacao:
set correlate_variable="co2Cz.txt"
::numero de geracoes (ou epocas) do algoritmo bayesiano (valores na ordem de milhoes):
set n=20000000
::os outputs para analise de convergencia serao produzidos com este espacamento, para
:: ficar mais enxuto (em vez de milhoes de linhas, desnecessariamente):
set s=5000
::burnin
set b=0.2
::burnin para o plot (tem que ser numero inteiro):
set bs=200
::singleton
::set singleton=1

:: abertura
echo.
echo ------------------------------------------------
echo                    # WELCOME! #
echo                Running testudinidae
echo              diversification analysis.
echo         (started at %date% - %time%)
echo ------------------------------------------------
echo.
pause
goto rcheck

:: checando R
:RCHECK
echo.
echo [%date% - %time%] STATUS: Checking for R in your system...
echo.
R --version >NUL 2>&1
if errorlevel 1 goto nor
echo.
echo [%date% - %time%] STATUS: ...R is successfully installed and running in your system.
echo.
pause
goto pythoncheck

:: erro R nao encontrado
:NOR
echo.
echo [%date% - %time%] STATUS: ...R is not in your PATH, checking if R is actually installed...
echo.
if exist "C:\Program Files\R" (
    echo [%date% - %time%] STATUS: R is actually installed, please insert in your PATH.
) else (
    echo [%date% - %time%] STATUS: R is not installed in your system.
)
goto end

:: checando python
:PYTHONCHECK
echo.
echo [%date% - %time%] STATUS: Checking for Python in your system...
echo.
python.exe --version >NUL 2>&1
if errorlevel 1 goto nopython
echo.
echo [%date% - %time%] STATUS: ...Python is successfully installed and running in your system.
echo.
pause
goto installpackages

::erro python
:NOPYTHON
echo.
echo [%date% - %time%] STATUS: python not found. Make sure it is installed and you are using Anaconda Prompt to run this program.
echo.
goto end

::instalando pacotes
:INSTALLPACKAGES
echo.
echo [%date% - %time%] STATUS: checking for necessary python packages...
echo.
pip3 install -r pyrate/requirements.txt
if errorlevel 1 goto pipinstallerror
echo.
echo [%date% - %time%] STATUS: packages installed (successfully, I hope!).
echo.
pause
goto loaddata

::erro pip install
:PIPINSTALLERROR
echo.
echo [%date% - %time%] STATUS: pip install failed.
echo.
goto end

::carregando dados
:LOADDATA
echo.
echo [%date% - %time%] STATUS: loading data...
echo.
Rscript data_loader_script.R
if errorlevel 1 goto dataloadererror
echo.
echo [%date% - %time%] STATUS: data successfully loaded.
echo.
pause
goto checkdata

::erro ao abrir e ajustar dados para input no PyRate
:DATALOADERERROR
echo.
echo [%date% - %time%] STATUS: Failed to load data.
echo.
goto end

::checando dados de input do pyrate
:CHECKDATA
echo.
cd PyRate
python PyRate.py ../%pbd_path% -data_info
cd ..
echo.
echo [%date% - %time%] STATUS: PyRate input data is fine.
echo.
pause
goto checkforjump1

::check para pular analise de diversificacao
:CHECKFORJUMP1
IF exist pyrate_mcmc_logs/ (
    goto checkforjump2
) ELSE (
    goto rundiversificationanalysis
)

:CHECKFORJUMP2
echo. 
set /p jump=An MCMC logs folder already exists for this project. ^
Please, type 1 to run diversification analysis again, 2 for just ^
plot the existing outputs, or 3 to jump to correlation analysis: 
echo.
IF %jump%==1 (
    goto runcorrelation
) ELSE IF %jump%==2 (
    goto makeplots
) ELSE IF %jump%==3 (
    goto runcorrelation
) ELSE (
    goto checkforjump2
)



@REM IF %jump%==y (goto runcorrelation) ELSE (goto checkforjump3)

@REM :CHECKFORJUMP3
@REM IF %jump%==n (goto rundiversificationanalysis) ELSE (goto checkforjump1)

@REM IF exist pyrate_mcmc_logs/ (
@REM     echo. 
@REM     set /p jump="Jump to correlation analysis? (y = yes; n = no) "
@REM     echo.
@REM     echo Inputed answer: %jump%
@REM     echo.
@REM     IF %jump%==y (
@REM         goto runcorrelation
@REM     ) ELSE (
@REM         IF %jump%==n (
@REM             goto rundiversificationanalysis
@REM         ) ELSE (
@REM             goto checkforjump
@REM         ) 
@REM     )
@REM ) ELSE (
@REM     goto rundiversificationanalysis
@REM )

::rodando analise de diversificacao
:RUNDIVERSIFICATIONANALYSIS
echo.
echo [%date% - %time%] STATUS: starting diversification analysis...
echo.
cd PyRate
::for /l %%i in (1,1,%max_rep%) do python PyRate.py ../%pbd_path% -A 4 -mHPP -mG -j %%i -n %n% -s %s% -b %b% -singleton %singleton% -thread 2 2 -out replicate_%%i
for /l %%i in (1,1,%max_rep%) do python PyRate.py ../%pbd_path% -A 4 -mHPP -mG -j %%i -n %n% -s %s% -b %b% -thread 2 2 -out replicate_%%i
if errorlevel 1 goto diversificationanalysiserror
cd ..
echo.
echo [%date% - %time%] STATUS: ...diversification analysis completed!
echo.
pause
goto makeplots

::erro na analise de diversificacao
:DIVERSIFICATIONANALYSISERROR
echo.
echo [%date% - %time%] STATUS: diversification analysis failed.
echo.
cd..
goto end

::fazendo os plots
:MAKEPLOTS
echo.
echo [%date% - %time%] STATUS: making plots...
echo.
cd PyRate
python PyRate.py -plotRJ ../%pyrate_mcmc_logs% -b %bs%
cd..
Rscript pyrate_mcmc_logs/RTT_plots.R
if errorlevel 1 goto diversificationanalysisploterror
::cd ..
echo.
echo [%date% - %time%] STATUS: ploting for diversification analysis completed.
echo.
goto correlationanalysis

::erro nos plot da analise de diversificacao
:DIVERSIFICATIONANALYSISPLOTERROR
echo.
echo [%date% - %time%] STATUS: ploting for diversification analysis failed.
echo.
cd..
goto end

::check analise de correlacao
:CORRELATIONANALYSIS
echo.
set /p corr="Run correlation analysis? (y = yes; n = no) "
echo.
echo Inputed answer: %corr%
echo.
IF %corr%==y (goto runcorrelation) ELSE ( IF %corr%==n (goto end) ELSE (goto correlationanalysis) )

::rodando analise de correlacao
:RUNCORRELATION
echo.
echo.
echo [%date% - %time%] STATUS: running correlation analysis...
echo.
cd PyRate
python PyRateContinuous.py -ginput ../%pyrate_mcmc_logs%
echo.
if errorlevel 1 goto correlationanalysiserror
::python PyRateContinuous.py -d ../%pyrate_mcmc_logs%/pbdb_data_1replicate_1_Grj_se_est.txt -c ../%correlate_variable% -m 0
for /l %%i in (1,1,%max_rep%) do python PyRateContinuous.py -d ../%pyrate_mcmc_logs%/pbdb_data_%%ireplicate_%%i_Grj_se_est.txt -c ../%correlate_variable% -m 0 -n %n%
echo.
if errorlevel 1 goto correlationanalysiserror
echo.
echo [%date% - %time%] STATUS: correlation analysis completed.
echo.
cd..
goto plotcorrelationanalysis

::erro na analise de correlacao
:CORRELATIONANALYSISERROR
echo.
echo [%date% - %time%] STATUS: correlation analysis failed.
echo.
cd..
goto end

::graficos
:PLOTCORRELATIONANALYSIS
echo.
echo.
echo [%date% - %time%] STATUS: plotting correlation analysis results...
echo.
Rscript correlation_plot_script.R %max_rep%
if errorlevel 1 goto correlationanalysiserror
echo.
echo [%date% - %time%] STATUS: ...plotting for correlation analysis completed.
echo.
goto end

::erro no plot da correlacao
:CORRELATIONANALYSISERROR
echo.
echo [%date% - %time%] STATUS: plotting for correlation analysis failed.
echo.
goto end

:: fechamento
:END
echo.
echo ---------------------------------------------------------------------
echo             ## Diversification analysis completed! ##
echo ---------------------------------------------------------------------
echo.