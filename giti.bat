@echo off
chcp 65001 > nul
echo ========================================
echo GITHUB REPOSITORY KOMPLETT ZURÜCKSETZEN
echo ========================================
echo.

echo WARNUNG: Dies löscht die komplette GitHub History
echo und ersetzt sie mit dem aktuellen Stand!
echo.
set /p confirm="Bist du sicher? (j/n): "
if /i not "%confirm%"=="j" (
    echo Abgebrochen.
    pause
    exit /b 0
)

echo.
echo [1/5] Entferne alte Dateien aus Git...
git rm -r --cached . 2>nul
echo ✓ Cache geleert
echo.

echo [2/5] Erstelle .gitignore...
(
echo # Python
echo __pycache__/
echo *.py[cod]
echo *$py.class
echo *.so
echo .Python
echo build/
echo develop-eggs/
echo dist/
echo downloads/
echo eggs/
echo .eggs/
echo lib/
echo lib64/
echo parts/
echo sdist/
echo var/
echo wheels/
echo *.egg-info/
echo .installed.cfg
echo *.egg
echo.
echo # Virtual Environment
echo .env
echo .venv
echo env/
echo venv/
echo ENV/
echo.
echo # IDE
echo .vscode/
echo .idea/
echo *.swp
echo *.swo
echo *~
echo.
echo # OS
echo .DS_Store
echo Thumbs.db
echo.
echo # Project specific - optional, kommentiere aus was du NICHT ignorieren willst
echo # *.whl
echo # *.bat
) > .gitignore
echo ✓ .gitignore erstellt
echo.

echo [3/5] Füge alle aktuellen Dateien hinzu...
git add .
echo ✓ Dateien hinzugefügt
echo.

echo [4/5] Erstelle neuen Commit...
git commit -m "Clean repository - fresh start with current files"
echo ✓ Commit erstellt
echo.

echo [5/5] Force Push zu GitHub (überschreibt alles!)...
git push -f origin master 2>nul
if errorlevel 1 (
    echo Branch 'master' fehlgeschlagen, versuche 'main'...
    git branch -M main
    git push -f origin main
    if errorlevel 1 (
        echo ❌ Push fehlgeschlagen!
        pause
        exit /b 1
    )
    echo ✓ Erfolgreich zu GitHub gepusht (Branch: main)
) else (
    echo ✓ Erfolgreich zu GitHub gepusht (Branch: master)
)

echo.
echo ========================================
echo ✓ FERTIG!
echo ========================================
echo.
echo Das GitHub Repository wurde komplett
echo zurückgesetzt und enthält jetzt nur noch
echo die aktuellen Dateien aus deinem Ordner.
echo.
echo Aktuelle Dateien im Repository:
git ls-files
echo.
pause