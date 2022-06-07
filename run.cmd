@echo off

:: DEFININDO AS VARIAVEIS
::numero de replicas:
set max_rep=1
::caminho relativo ate o arquivo pbdb_data_PyRate.py:
set pbd_path="pbdb_data_PyRate.py"
:: caminho relativo para a pasta MCMC logs:
set pyrate_mcmc_logs="pyrate_mcmc_logs"
::numero de geracoes (ou epocas) do algoritmo bayesiano (valores na ordem de milhoes):
set n=10000
::os outputs para analise de convergencia serao produzidos com este espacamento, para
:: ficar mais enxuto (em vez de milhoes de linhas, desnecessariamente):
set s=5
::burnin
set b=0.2
::burnin para o plot (tem que ser numero inteiro):
set bs=10
::singleton
set singleton=1

:: abertura
echo.
echo ------------------------------------------------
echo                  # BEM VINDO #
echo                Rodando análise de  
echo          diversificação de testudinidae.
echo ------------------------------------------------
echo.
pause
goto rcheck

:: checando R
:RCHECK
echo.
echo STATUS: Checking for R in your system...
echo.
R --version >NUL 2>&1
if errorlevel 1 goto nor
echo.
echo STATUS: ...R is successfully installed and running in your system.
echo.
pause
goto pythoncheck

:: erro R nao encontrado
:NOR
::mkdir temp
::cd temp
::echo.
::echo STATUS: baixando R...
::echo.
::curl https://cran.r-project.org/bin/windows/base/R-4.2.0-win.exe -o rinstaller.exe
::echo.
::rinstaller.exe
::echo STATUS: R successfully installed.
::cd..
::echo.
echo.
echo STATUS: ...R is not in your PATH, checking if R is actually installed...
echo.
if exist "C:\Program Files\R" (
    echo STATUS: R is actually installed, please insert in your PATH.
) else (
    echo STATUS: R is not installed in your system.
)
pause
goto end

:: checando python
:PYTHONCHECK
echo.
echo STATUS: Checking for Python in your system...
echo.
python.exe --version >NUL 2>&1
if errorlevel 1 goto nopython
echo.
echo STATUS: ...Python is successfully installed and running in your system.
echo.
pause
goto installpackages

::erro python
:NOPYTHON
echo.
echo STATUS: python not found. Make sure it is installed and you are using Anaconda Prompt to run this program.
echo.
goto end

::instalando pacotes
:INSTALLPACKAGES
echo.
echo STATUS: checking for necessary python packages...
echo.
pip3 install -r pyrate/requirements.txt
if errorlevel 1 goto pipinstallerror
echo.
echo STATUS: packages installed (successfully, I hope!).
echo.
pause
goto loaddata

::erro pip install
:PIPINSTALLERROR
echo.
echo STATUS: pip install failed.
echo.
pause
goto end

::carregando dados
:LOADDATA
echo.
echo STATUS: loading data...
echo.
Rscript data_loader_script.R
if errorlevel 1 goto dataloadererror
echo.
echo STATUS: data successfully loaded.
echo.
pause
goto checkdata

::erro ao abrir e ajustar dados para input no PyRate
:DATALOADERERROR
echo.
echo STATUS: Failed to load data.
echo.
goto end

::checando dados de input do pyrate
:CHECKDATA
echo.
cd PyRate
python PyRate.py ../%pbd_path% -data_info
cd ..
echo.
echo STATUS: PyRate input data is fine.
echo.
pause
goto rundiversificationanalysis

::rodando analise de diversificacao
:RUNDIVERSIFICATIONANALYSIS
echo.
echo STATUS: starting diversification analysis...
echo.
cd PyRate
for /l %%i in (1,1,%max_rep%) do python PyRate.py ../%pbd_path% -A 4 -mHPP -mG -j %%i -n %n% -s %s% -b %b% -singleton %singleton% -thread 2 2 -out replicate_%%i
if errorlevel 1 goto diversificationanalysiserror
cd ..
echo.
echo STATUS: ...diversification analysis completed!
echo.
pause
goto makeplots

::erro na analise de diversificacao
:DIVERSIFICATIONANALYSISERROR
echo.
echo STATUS: diversification analysis failed.
echo.
cd..
pause
goto end

::fazendo os plots
:MAKEPLOTS
echo.
echo STATUS: making plots...
echo.
cd PyRate
python PyRate.py -plotRJ ../%pyrate_mcmc_logs% -b %bs% -tag pbdb_data
cd..
Rscript pyrate_mcmc_logs/RTT_plots.R
if errorlevel 1 goto diversificationanalysisploterror
::cd ..
echo.
echo STATUS: ploting for diversification analysis completed.
echo.
pause
goto end

::erro nos plot da analise de diversificacao
:DIVERSIFICATIONANALYSISPLOTERROR
echo.
echo STATUS: ploting for diversification analysis failed.
echo.
cd..
pause
goto end

:: fechamento
:END
echo.
echo -----------------------------------
echo             ## FIM ##
echo -----------------------------------
echo.