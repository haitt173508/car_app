from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models

# Create your models here.


class UserManager(BaseUserManager):
    def create_user(self, username, name, phone, age, user_type, address=None,
                    email=None, password=None, avatar_url=None):
        user = self.model(
            username=username,
            name=name,
            phone=phone,
            age=age,
            user_type=user_type,
            address=address,
            email=self.normalize_email(email),
            avatar_url=avatar_url,
        )

        user.set_password(password)
        user.save(using=self._db)
        return user

    # def create(self, username, name, phone, age, user_type, address=None, email=None, password=None):
    #     user = self.create_user(
    #         username=username,
    #         name=name,
    #         phone=phone,
    #         age=age,
    #         user_type=user_type,
    #         email=email,
    #         address=address,
    #         password=password,
    #     )

    #     return user

    def create_superuser(self, username, name, phone, age, user_type,
                         address=None, email=None, password=None, avatar_url=None):
        user = self.create_user(
            username=username,
            name=name,
            phone=phone,
            age=age,
            user_type=user_type,
            email=email,
            address=address,
            password=password,
            avatar_url=avatar_url,
        )
        user.is_admin = True
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)

        return user


class User(AbstractBaseUser):

    USER_TYPE_CHOICE = [
        (1, 'Customer'),
        (2, 'Driver'),
    ]

    username = models.CharField(max_length=30, unique=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(null=True, auto_now_add=True)
    is_admin = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)
    name = models.CharField(max_length=30)
    phone = models.CharField(max_length=12)
    email = models.CharField(null=True, max_length=100)
    address = models.CharField(null=True, max_length=100)
    date_updated = models.DateTimeField(null=True, auto_now=True)
    age = models.SmallIntegerField()
    user_type = models.SmallIntegerField(choices=USER_TYPE_CHOICE)
    avatar_url = models.TextField(null=True)

    objects = UserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['phone', 'age', 'user_type', 'name']

    def __str__(self):
        return self.username

    def has_perm(self, perm, obj=None):
        return self.is_admin

    def has_module_perms(self, app_label):
        return True
