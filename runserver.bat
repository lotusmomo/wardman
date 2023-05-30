SET PYTHON="%USERPROFILE%\anaconda3\envs\django-3.2.19\python.exe"
SET DJANGO_MANAGE="src\wardman\manage.py"
SET PORT=8000

%PYTHON% %DJANGO_MANAGE% runserver %PORT%