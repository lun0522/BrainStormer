# coding: utf-8

import os

DEBUG = os.environ.get('LEANCLOUD_APP_ENV') != 'production'
ROOT_URLCONF = 'urls'
SECRET_KEY = 'taVP3U4xG0JyFp5WM58ckSMA'
ALLOWED_HOSTS = ['*']

TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': ['templates'],
}]
