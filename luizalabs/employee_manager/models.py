import re

from django.core.exceptions import ValidationError
from django.db import models

EMAIL_REGEX = re.compile(r'[^@]+@[^@]+\.[^@]+')


def validate_email(value):
    """
    Check that the email is valid.
    """
    if not EMAIL_REGEX.match(value):
        raise ValidationError('Invalid email address')
    return value


class Employee(models.Model):
    name = models.CharField(max_length=100)
    email = models.CharField(max_length=50, unique=True,
                             validators=[validate_email])
    department = models.CharField(max_length=100)
