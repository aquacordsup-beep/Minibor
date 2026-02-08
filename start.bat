@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ========================================
echo PyPI Publishing Workflow Setup (Advanced)
echo ========================================
echo.

REM Erstelle .github/workflows Verzeichnis
if not exist ".github\workflows" (
    mkdir .github\workflows
)

REM Frage Benutzer nach Optionen
echo Wähle die Publishing-Option:
echo 1. Nur PyPI (Production)
echo 2. PyPI + TestPyPI (empfohlen)
echo 3. Nur TestPyPI (zum Testen)
echo.
set /p choice="Deine Wahl (1-3): "

if "%choice%"=="1" goto pypi_only
if "%choice%"=="2" goto both
if "%choice%"=="3" goto testpypi_only

:pypi_only
echo.
echo Erstelle PyPI-Only Workflow...
(
echo name: Publish to PyPI
echo.
echo on:
echo   push:
echo     tags:
echo       - 'v*'
echo   workflow_dispatch:
echo.
echo jobs:
echo   publish:
echo     runs-on: ubuntu-latest
echo     
echo     steps:
echo     - uses: actions/checkout@v3
echo     
echo     - name: Set up Python
echo       uses: actions/setup-python@v4
echo       with:
echo         python-version: '3.x'
echo     
echo     - name: Install dependencies
echo       run: ^|
echo         python -m pip install --upgrade pip
echo         pip install build twine
echo     
echo     - name: Build package
echo       run: python -m build
echo     
echo     - name: Publish to PyPI
echo       env:
echo         TWINE_USERNAME: __token__
echo         TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
echo       run: twine upload dist/*
) > .github\workflows\publish.yml
goto finish

:both
echo.
echo Erstelle PyPI + TestPyPI Workflow...
(
echo name: Publish Package
echo.
echo on:
echo   push:
echo     tags:
echo       - 'v*'
echo     branches:
echo       - main
echo       - master
echo   workflow_dispatch:
echo.
echo jobs:
echo   test-publish:
echo     name: Publish to TestPyPI
echo     runs-on: ubuntu-latest
echo     if: github.event_name == 'push' ^&^& !startsWith(github.ref, 'refs/tags/')
echo     
echo     steps:
echo     - uses: actions/checkout@v3
echo     
echo     - name: Set up Python
echo       uses: actions/setup-python@v4
echo       with:
echo         python-version: '3.x'
echo     
echo     - name: Install dependencies
echo       run: ^|
echo         python -m pip install --upgrade pip
echo         pip install build twine
echo     
echo     - name: Build package
echo       run: python -m build
echo     
echo     - name: Publish to TestPyPI
echo       env:
echo         TWINE_USERNAME: __token__
echo         TWINE_PASSWORD: ${{ secrets.TEST_PYPI_API_TOKEN }}
echo       run: twine upload --repository testpypi dist/*
echo.
echo   production-publish:
echo     name: Publish to PyPI
echo     runs-on: ubuntu-latest
echo     if: github.event_name == 'push' ^&^& startsWith(github.ref, 'refs/tags/v')
echo     
echo     steps:
echo     - uses: actions/checkout@v3
echo     
echo     - name: Set up Python
echo       uses: actions/setup-python@v4
echo       with:
echo         python-version: '3.x'
echo     
echo     - name: Install dependencies
echo       run: ^|
echo         python -m pip install --upgrade pip
echo         pip install build twine
echo     
echo     - name: Build package
echo       run: python -m build
echo     
echo     - name: Publish to PyPI
echo       env:
echo         TWINE_USERNAME: __token__
echo         TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
echo       run: twine upload dist/*
) > .github\workflows\publish.yml
goto finish

:testpypi_only
echo.
echo Erstelle TestPyPI-Only Workflow...
(
echo name: Publish to TestPyPI
echo.
echo on:
echo   push:
echo     branches:
echo       - main
echo       - master
echo   workflow_dispatch:
echo.
echo jobs:
echo   publish:
echo     runs-on: ubuntu-latest
echo     
echo     steps:
echo     - uses: actions/checkout@v3
echo     
echo     - name: Set up Python
echo       uses: actions/setup-python@v4
echo       with:
echo         python-version: '3.x'
echo     
echo     - name: Install dependencies
echo       run: ^|
echo         python -m pip install --upgrade pip
echo         pip install build twine
echo     
echo     - name: Build package
echo       run: python -m build
echo     
echo     - name: Publish to TestPyPI
echo       env:
echo         TWINE_USERNAME: __token__
echo         TWINE_PASSWORD: ${{ secrets.TEST_PYPI_API_TOKEN }}
echo       run: twine upload --repository testpypi dist/*
) > .github\workflows\publish.yml
goto finish

:finish
echo.
echo ✓ Workflow-Datei erstellt!
echo.

REM Git Operationen
set /p do_git="Soll ich die Datei auch zu Git hinzufügen und pushen? (j/n): "
if /i "%do_git%"=="j" (
    git add .github\workflows\publish.yml
    git commit -m "Add PyPI publishing workflow"
    git push
    echo ✓ Zu GitHub gepusht!
)

echo.
echo ========================================
echo NÄCHSTE SCHRITTE:
echo ========================================
echo.

if "%choice%"=="1" (
    echo 1. PyPI Token erstellen:
    echo    https://pypi.org/manage/account/token/
    echo.
    echo 2. GitHub Secret hinzufügen:
    echo    Name: PYPI_API_TOKEN
    echo    Value: [Dein Token]
    echo.
    echo 3. Tag erstellen und pushen:
    echo    git tag v1.0.0
    echo    git push origin v1.0.0
)

if "%choice%"=="2" (
    echo 1. TestPyPI Token erstellen:
    echo    https://test.pypi.org/manage/account/token/
    echo.
    echo 2. PyPI Token erstellen:
    echo    https://pypi.org/manage/account/token/
    echo.
    echo 3. GitHub Secrets hinzufügen:
    echo    - TEST_PYPI_API_TOKEN
    echo    - PYPI_API_TOKEN
    echo.
    echo 4. Testen mit Push zu main/master
    echo    Produktiv-Release mit Tag:
    echo    git tag v1.0.0
    echo    git push origin v1.0.0
)

if "%choice%"=="3" (
    echo 1. TestPyPI Token erstellen:
    echo    https://test.pypi.org/manage/account/token/
    echo.
    echo 2. GitHub Secret hinzufügen:
    echo    Name: TEST_PYPI_API_TOKEN
    echo    Value: [Dein Token]
    echo.
    echo 3. Push zu main/master triggert Upload
)

echo.
echo ========================================
pause