"""
这里包含了项目的 URL 声明，每个 URL 声明都映射到一个视图函数
"""

from django.urls import path
from . import views

"""
函数 path() 具有四个参数
两个必须参数：route 和 view
两个可选参数：kwargs 和 name
"""

urlpatterns = [
    # 登录
    path('login/',             views.login),
    # 主页
    path('',                   views.index),
    # 科室
    path('department/',        views.department),
    path('department/add/',    views.department_add),
    path('department/edit/',   views.department_edit),
    path('department/delete/', views.department_delete),
    # 医生
    path('doctor/',            views.doctor),
    path('doctor/add/',        views.doctor_add),
    path('doctor/edit/',       views.doctor_edit),
    path('doctor/delete/',     views.doctor_delete),
    # 患者
    path('patient/',           views.patient),
    path('patient/add/',       views.patient_add),
    path('patient/edit/',      views.patient_edit),
    path('patient/delete/',    views.patient_delete),
    # 病房
    path('ward/',              views.ward),
    path('ward/add/',          views.ward_add),
    path('ward/edit/',         views.ward_edit),
    path('ward/delete/',       views.ward_delete),
    # 床位
    path('bed/',               views.bed),
    path('bed/add/',           views.bed_add),
    path('bed/edit/',          views.bed_edit),
    path('bed/delete/',        views.bed_delete),
    # 电子病历
    path('treatment/',         views.treatment),
    path('treatment/add/',     views.treatment_add),
    path('treatment/edit/',    views.treatment_edit),
    path('treatment/delete/',  views.treatment_delete),
    # 入院登记
    path('checkin/',           views.checkin),
    path('checkin/add/',       views.checkin_add),
    path('checkin/delete/',    views.checkin_delete),
]