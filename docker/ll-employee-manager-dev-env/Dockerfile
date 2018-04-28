FROM python:3.7-rc-slim

RUN pip install django && \
    pip install djangorestframework

EXPOSE 8000

ENV PYTHONPATH /ll-employee-manager/luizalabs

ENTRYPOINT python /ll-employee-manager/manage.py runserver 0:8000
