import json

from django.contrib.auth.models import User
from django.core.handlers.wsgi import WSGIHandler
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APITestCase

from ..wsgi import application


class EmployeeTests(APITestCase):

    def setUp(self):
        password = 'pass'
        user = User.objects.create_user(username='admin', password=password)
        self.client.login(username=user.username, password=password)
        self.employee = {
            'name': 'Diogo',
            'email': 'diogo@luizalabs.com',
            'department': 'Architecture'
        }
        self.client.post('/employee', format='json',
                         data=self.employee)

    def test_reponse_default_indent(self):
        response = self.client.get('/employee', format='json')
        expected_content = expected_content = json.dumps(
            [self.employee], indent=2
        ).encode()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.content, expected_content)

    def test_get_employees_with_ending_slash(self):
        response = self.client.get('/employee/', format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_post_with_invalid_email_address(self):
        employee = {
            'name': 'Diogo',
            'email': 'diogo',
            'department': 'Architecture'
        }
        expected_content = json.dumps({
            'email': ['Invalid email address']
        }, indent=2).encode()
        response = self.client.post('/employee', format='json', data=employee)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.content, expected_content)


class TestWsgi(TestCase):
    def test_wsgi_app(self):
        self.assertEqual(isinstance(application, WSGIHandler), True)
