@echo off
setlocal enabledelayedexpansion
@echo "begin unit test"
pushd .
cd sdk\binary\[build]\bin\x86\Release\

del /Q vstest_error_log.txt
rmdir /s /q TestResults
set PATH=%PATH%;%CD%;
"%VS150COMNTOOLS%..\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe" WebexSDKTests.dll /InIsolation /EnableCodeCoverage /Logger:trx /Settings:..\..\..\..\..\..\sdk\WebexSDKTests\CodeCoverage.runsettings 2>vstest_error_log.txt

for /f "delims=" %%i in ('dir/s/b TestResults\*.coverage') do (
set coverageFile=%%i
goto b)
:b
echo coverageFile: %coverageFile%

echo vstest.console.exe exit code is %errorlevel%
set "abort_flag=the execution process exited unexpectedly"

if not '%errorlevel%' == '0' (
    echo "test cases failed or test process exit"
    if exist vstest_error_log.txt (
        set /p vstest_error=<vstest_error_log.txt
        echo "---s"
        set vstest_error=!vstest_error!log
        echo !vstest_error!
        echo "---e"
        echo %abort_flag%

CALL set "test=!!vstest_error:%abort_flag%=!!"
echo !test!
if "!test!"=="!vstest_error!" (
	"%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\Team Tools\Dynamic Code Coverage Tools\CodeCoverage.exe" analyze /output:TestResults\VisualStudio.coveragexml "%coverageFile%"
     ..\..\..\..\..\..\bin\CoverageConverter.exe /in:TestResults/*.coverage /out:TestResults/vstest.coveragexml
	 
) else ( 
     rmdir /s /q TestResults
     echo "don't calculate coverage because the test process exited unexpectly"
)
    )
    (call ) 
    echo %errorlevel%
) else (
"%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\Team Tools\Dynamic Code Coverage Tools\CodeCoverage.exe" analyze /output:TestResults\VisualStudio.coveragexml "%coverageFile%"
..\..\..\..\..\..\bin\CoverageConverter.exe /in:TestResults/*.coverage /out:TestResults/vstest.coveragexml
)
echo %errorlevel%
popd
