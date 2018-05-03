FROM dutradda/ll-employee-manager-base

RUN pip install gunicorn

COPY dist/ll-employee-manager /ll-employee-manager
COPY nginx.conf /etc/sites-enabled/employee-manager.conf

EXPOSE 8000

ENTRYPOINT gunicorn -b :8000 luizalabs.wsgi
