FROM dutradda/ll-employee-manager-base

COPY manage.py /ll-employee-manager/manage.py
COPY ll_employee_manager /ll-employee-manager/

EXPOSE 8000

ENTRYPOINT python /ll-employee-manager/manage.py runserver
