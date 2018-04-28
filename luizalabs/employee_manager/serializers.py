from .models import Employee
from rest_framework import serializers

import re

EMAIL_REGEX = re.compile(r'[^@]+@[^@]+\.[^@]+')


class EmployeeSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Employee
        fields = ('name', 'email', 'department')

    def validate_email(self, value):
        """
        Check that the email is valid.
        """
        if not EMAIL_REGEX.match(value):
            raise serializers.ValidationError('Invalid email address')
        return value
