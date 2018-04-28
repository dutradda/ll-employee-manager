from django.conf.urls import include, url
from rest_framework.routers import SimpleRouter

from . import views


class OptionalSlashRouter(SimpleRouter):

    def __init__(self):
        self.trailing_slash = '/?'
        super(SimpleRouter, self).__init__()


router = OptionalSlashRouter()
router.register(r'employee', views.EmployeeViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
]
