from django.shortcuts import render, redirect, HttpResponse
from django.core.signing import BadSignature
import sys
sys.path.append('.')
from .config import __SALT, __SUPER_USERNAME, __SUPER_PASSWORD
from .utils import MyHelper

def login(request):
    conn = MyHelper()
    user_dict = conn.get_list('SELECT * FROM login_view')
    print(user_dict)
    conn.close()
    if request.method == 'GET':
        obj = render(request, 'login.html', {'error': ''})
        obj.delete_cookie('ticket')
        obj.delete_cookie('privilege')
        return obj
    elif request.method == "POST":
        username = request.POST.get('username', None)
        password = request.POST.get('password', None)
        if username == __SUPER_USERNAME and password == __SUPER_PASSWORD :
            obj = redirect('/')
            obj.set_signed_cookie('ticket', __SUPER_USERNAME, salt=__SALT)
            obj.set_signed_cookie('privilege', '255', salt=__SALT)
            return obj
        else :
            for user in user_dict:
                if user['user'] == username and user['pass'] == password:
                    obj = redirect('/')
                    obj.set_signed_cookie('ticket', username, salt=__SALT)
                    obj.set_signed_cookie('privilege', user['privilege'], salt=__SALT)
                    return obj
            return render(request, 'login.html', {'error': '用户名或密码错误！'})

def index(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    conn = MyHelper()
    context = {}
    if ticket == __SUPER_USERNAME:
        context['username'] = __SUPER_USERNAME
        context['privilege'] = '超级管理员'
        context['hidden'] = 'hidden'
    elif request.method == 'GET':
        context['username'] = conn.get_one(f'SELECT * FROM `login_view` WHERE `user` = {ticket}')['name']
        user_privilege = conn.get_one(f'SELECT `privilege` FROM login_view WHERE user = {ticket}')
        if user_privilege['privilege'] == '1':
            context['privilege'] = '医生'
        else:
            context['privilege'] = '患者'
    else:
        context['username'] = conn.get_one(f'SELECT * FROM `login_view` WHERE `user` = {ticket}')['name']
        user_privilege = conn.get_one(f'SELECT `privilege` FROM login_view WHERE user = {ticket}')
        if user_privilege['privilege'] == '1':
            context['privilege'] = '医生'
        else:
            context['privilege'] = '患者'
        oldpass = request.POST.get('oldpass')
        newpass = request.POST.get('newpass')
        if oldpass != conn.get_one(f'SELECT `pass` FROM login_view WHERE user = {ticket}')['pass']:
            context['error'] = '原密码错误！'
        elif int(request.get_signed_cookie('privilege', salt=__SALT)) == 0:
            sql = f'UPDATE `patient` SET `pass` = "{newpass}" WHERE `tel` = "{ticket}"'
            print(sql)
            conn.modify(sql)
            context['error'] = '修改成功！'
        elif int(request.get_signed_cookie('privilege', salt=__SALT)) == 1:
            sql = f'UPDATE `doctor` SET `pass` = "{newpass}" WHERE `id` = "{ticket}"'
            print(sql)
            conn.modify(sql)
            context['error'] = '修改成功！'
        else:
            context['error'] = '修改失败！'
    conn.close()
    return render(request, 'index.html', context)

def department(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('/login/')
    conn = MyHelper()
    department_list = conn.get_list('SELECT * FROM department')
    print(department_list)
    conn.close()
    return render(request, 'department/index.html', {'department_list': department_list})

def department_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    else :
        if request.method == 'POST':
            keys = ['name', 'tel', 'location']
            new = {}
            for key in keys:
                new[key] = request.POST.get(key)
            print("DATA from POST: ", new)
            sql = f'INSERT INTO `department` (`name`, `tel`, `location`) VALUES ("{new["name"]}", "{new["tel"]}", "{new["location"]}")'
            print(sql)
            conn = MyHelper()
            conn.create(sql)
            conn.close()
            return redirect('/department/')
        return render(request, 'department/add.html')
    
def department_edit(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    else:
        if request.method == 'GET':
            id = request.GET.get('id')
            context = {}
            context['id'] = id
            conn = MyHelper()
            context = conn.get_one(f'SELECT * FROM department WHERE id = {id}')
            return render(request, 'department/edit.html', context)
        else:
            new = {'id': request.GET.get('id')}
            for key in ['name', 'tel', 'location']:
                new[key] = request.POST.get(key)
            print("DATA from GET & POST: ", new)
            sql = f'UPDATE `department` SET name = "{new["name"]}", tel = "{new["tel"]}", location = "{new["location"]}" WHERE id = {new["id"]}'
            print(sql)
            conn = MyHelper()
            conn.modify(sql)
            conn.close()
            return redirect('/department/')

def department_delete(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    elif request.method != 'POST':
        return HttpResponse('请求错误！')
    else:
        conn = MyHelper()
        id = request.POST.get('id')
        conn.modify(f'DELETE FROM department WHERE id = {id}')
        conn.close()
        return HttpResponse('ok')

def doctor(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    conn = MyHelper()
    doctor_list = conn.get_list('SELECT * FROM doctor_view')
    print(doctor_list)
    conn.close()
    return render(request, 'doctor/index.html', {'doctor_list': doctor_list})

def doctor_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    else :
        context = {}
        conn = MyHelper()
        if request.method == 'POST':
            name = request.POST.get('name')
            gender = request.POST.get('gender')
            tel = request.POST.get('tel')
            dep = request.POST.get('dep')
            ssn = request.POST.get('ssn')
            password = request.POST.get('password')
            print(name, gender, tel, ssn, dep, password)
            sql = f'INSERT INTO `doctor` (`name`, `gender`, `tel`, `ssn`, `dep`, `pass`) VALUES ("{name}", "{gender}", "{tel}", "{ssn}", "{dep}", "{password}")'
            print(sql)
            try:
                conn.create(sql)
            except:
                context['error'] = '身份证号有误！'
                department_list = conn.get_list('SELECT * FROM department')
                context['deps'] = department_list
                return render(request, 'doctor/add.html', context)
            conn.close()
            return redirect('/doctor/')
        else:
            conn = MyHelper()
            department_list = conn.get_list('SELECT * FROM department')
            conn.close()
            context['deps'] = department_list
            return render(request, 'doctor/add.html', context)

def doctor_edit(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    else:
        if request.method == 'GET':
            context = {'id': request.GET.get('id')}
            conn = MyHelper()
            context = conn.get_one(f'SELECT * FROM doctor_view WHERE id = {request.GET.get("id")}')
            context['deps'] = conn.get_list('SELECT `id`, `name` FROM department')
            print(context)
            return render(request, 'doctor/edit.html', context)
        else:
            new = {'id': request.GET.get('id')}
            keys = ['name', 'gender', 'tel', 'ssn', 'dep']
            for key in keys:
                new[key] = request.POST.get(key)
            sql = f'UPDATE `doctor` SET name = "{new["name"]}", gender = "{new["gender"]}", tel = "{new["tel"]}", ssn = "{new["ssn"]}", dep = "{new["dep"]}" WHERE id = "{new["id"]}"'
            print("\033[33m", new, sql, "\033[0m")
            conn = MyHelper()
            conn.modify(sql)
            conn.close()
            return redirect('/doctor/')

def doctor_delete(request):
    if int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
        else:
            if ticket is None:
                return HttpResponse('请先登录！')
            elif request.method != 'POST':
                return HttpResponse('请求错误！')
            else:
                conn = MyHelper()
                id = request.POST.get('id')
                conn.modify(f'DELETE FROM `doctor` WHERE id = {id}')
                conn.close()
                return HttpResponse('ok')

def patient(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    else:
        conn = MyHelper()
        patient_list = conn.get_list('SELECT * FROM patient_view')
        conn.close()
        print(patient_list)
        return render(request, 'patient/index.html', {'list': patient_list})
    
def patient_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    else:
        conn = MyHelper()
        if request.method == 'POST':
            keys = ['name', 'gender', 'tel', 'ssn', 'blood', 'online', 'pass']
            new = {}
            for key in keys:
                new[key] = request.POST.get(key)
            sql = f'INSERT INTO `patient` (`name`, `gender`, `tel`, `ssn`, `blood`, `online`, `pass`) VALUES ("{new["name"]}", "{new["gender"]}", "{new["tel"]}", "{new["ssn"]}", "{new["blood"]}", "{new["online"]}", "{new["pass"]}")'
            print("\033[33m", new, "\n", sql, "\033[0m")
            try:
                conn.create(sql)
            except:
                conn.close()
                context = {'error': '身份证号有误！'}
                return render(request, 'patient/add.html', context)
            conn.close()
            return redirect('/patient/')
        else:
            return render(request, 'patient/add.html')

def patient_edit(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    else:
        if request.method == 'GET':
            context = {'ssn': request.GET.get('ssn')}
            conn = MyHelper()
            context = conn.get_one(f'SELECT * FROM patient WHERE ssn = {request.GET.get("ssn")}')
            print(context)
            return render(request, 'patient/edit.html', context)
        else:
            new = {'ssn': request.GET.get('ssn')}
            keys = ['name', 'gender', 'tel', 'blood', 'online']
            for key in keys:
                new[key] = request.POST.get(key)
            sql = f'UPDATE `patient` SET name = "{new["name"]}", gender = "{new["gender"]}", tel = "{new["tel"]}", blood = "{new["blood"]}", online = "{new["online"]}" WHERE ssn = "{new["ssn"]}"'
            print("\033[33m", new, "\n", sql, "\033[0m")
            conn = MyHelper()
            conn.modify(sql)
            conn.close()
            return redirect('/patient/')

def patient_delete(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
        else:
            if ticket is None:
                return HttpResponse('请先登录！')
            elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
                return HttpResponse('权限不足！')
            elif request.method != 'POST':
                return HttpResponse('请求错误！')
            else:
                conn = MyHelper()
                id = request.POST.get('id')
                conn.modify(f'DELETE FROM `patient` WHERE ssn = {id}')
                conn.close()
                return HttpResponse('ok')

def ward(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    conn = MyHelper()
    ward_list = conn.get_list('SELECT * FROM ward_view')
    conn.close()
    print(ward_list)
    return render(request, 'ward/index.html', {'list': ward_list})

def ward_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    else :
        context = {}
        conn = MyHelper()
        if request.method == 'POST':
            keys = ["did", "location"]
            context = {}
            for key in keys:
                context[key] = request.POST.get(key)
            print(context)
            sql = f'INSERT INTO `ward` (`dep`, `location`) VALUES ("{context["did"]}", "{context["location"]}")'
            print(sql)
            conn.create(sql)
            conn.close()
            return redirect('/ward/')
        else:
            deps = conn.get_list('SELECT * FROM department')
            print(list)
            conn.close()
            return render(request, 'ward/add.html', {'deps': deps})

def ward_edit(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    else:
        if request.method == 'GET':
            context = {'id': request.GET.get('id')}
            conn = MyHelper()
            context = conn.get_one(f'SELECT * FROM ward WHERE id = {request.GET.get("id")}')
            context['deps'] = conn.get_list('SELECT * FROM department')
            print(context)
            return render(request, 'ward/edit.html', context)
        else:
            new = {'id': request.GET.get('id')}
            keys = ['did', 'location']
            for key in keys:
                new[key] = request.POST.get(key)
            sql = f'UPDATE `ward` SET dep = "{new["did"]}", location = "{new["location"]}" WHERE id = "{new["id"]}"'
            print("\033[33m", new, "\n", sql, "\033[0m")
            conn = MyHelper()
            conn.modify(sql)
            conn.close()
            return redirect('/ward/')
        #return render(request, 'ward/edit.html')

def ward_delete(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
        else:
            if ticket is None:
                return HttpResponse('请先登录！')
            elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
                return HttpResponse('权限不足！')
            elif request.method != 'POST':
                return HttpResponse('请求错误！')
            else:
                conn = MyHelper()
                id = request.POST.get('id')
                conn.modify(f'DELETE FROM `ward` WHERE id = {id}')
                conn.close()
                return HttpResponse('ok')

def bed(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    conn = MyHelper()
    bed_list = conn.get_list('SELECT * FROM bed_view')
    conn.close()
    return render(request, 'bed/index.html', {'list': bed_list})

def bed_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    else :
        context = {}
        conn = MyHelper()
        if request.method == 'POST':
            keys = ["ward", "occupy"]
            for key in keys:
                context[key] = request.POST.get(key)
            print(context)
            sql = f'INSERT INTO `bed` (`ward`, `occupy`) VALUES ("{context["ward"]}", "{context["occupy"]}")'
            print(sql)
            conn.create(sql)
            conn.close()
            return redirect('/bed/')
        else:
            wards = conn.get_list('SELECT * FROM ward')
            print(list)
            conn.close()
            return render(request, 'bed/add.html', {'list': wards})

def bed_edit(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
        return HttpResponse('权限不足！')
    else:
        if request.method == 'GET':
            context = {'id': request.GET.get('id')}
            conn = MyHelper()
            context = conn.get_one(f'SELECT * FROM bed WHERE id = {request.GET.get("id")}')
            context['list'] = conn.get_list('SELECT * FROM ward')
            print(context)
            return render(request, 'bed/edit.html', context)
        else:
            new = {'id': request.GET.get('id')}
            keys = ['ward', 'occupy']
            for key in keys:
                new[key] = request.POST.get(key)
            sql = f'UPDATE `bed` SET ward = "{new["ward"]}", occupy = "{new["occupy"]}" WHERE id = "{new["id"]}"'
            print("\033[33m", new, "\n", sql, "\033[0m")
            conn = MyHelper()
            conn.modify(sql)
            conn.close()
            return redirect('/bed/')

def bed_delete(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
        else:
            if ticket is None:
                return HttpResponse('请先登录！')
            elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
                return HttpResponse('权限不足！')
            elif request.method != 'POST':
                return HttpResponse('请求错误！')
            else:
                conn = MyHelper()
                id = request.POST.get('id')
                conn.modify(f'DELETE FROM `bed` WHERE id = {id}')
                conn.close()
                return HttpResponse('ok')

def treatment(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    conn = MyHelper()
    list = conn.get_list('SELECT * FROM treatment_view')
    conn.close()
    print(list)
    return render(request, 'treatment/index.html', {'list': list})

def treatment_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    else :
        context = {}
        conn = MyHelper()
        if request.method == 'POST':
            keys = ['pid', 'did', 'content']
            for key in keys:
                context[key] = request.POST.get(key)
            print(context)
            sql = f'INSERT INTO `treatment` (`patient`, `doc`, `content`) VALUES ("{context["pid"]}", "{context["did"]}", "{context["content"]}")'
            print(sql)
            conn.create(sql)
            conn.close()
            return redirect('/treatment/')
        else:
            pids = conn.get_list('SELECT `ssn` AS `id`, `name` FROM patient')
            dids = conn.get_list('SELECT `id`, `name` FROM doctor')
            print(pids, "\n", dids)
            conn.close()
            return render(request, 'treatment/add.html', {'pids': pids, 'dids': dids})

def treatment_edit(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 1:
        return HttpResponse('权限不足！')
    else:
        if request.method == 'GET':
            context = {'id': request.GET.get('id')}
            conn = MyHelper()
            context = conn.get_one(f'SELECT * FROM treatment_view WHERE id = {request.GET.get("id")}')
            return render(request, 'treatment/edit.html', context)
        else:
            new = {'id': request.GET.get('id')}
            keys = ['content']
            for key in keys:
                new[key] = request.POST.get(key)
            sql = f'UPDATE `treatment` SET content = "{new["content"]}" WHERE id = "{new["id"]}"'
            print("\033[33m", new, "\n", sql, "\033[0m")
            conn = MyHelper()
            conn.modify(sql)
            conn.close()
            return redirect('/treatment/')

def treatment_delete(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
        else:
            if ticket is None:
                return HttpResponse('请先登录！')
            elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
                return HttpResponse('权限不足！')
            elif request.method != 'POST':
                return HttpResponse('请求错误！')
            else:
                conn = MyHelper()
                id = request.POST.get('id')
                conn.modify(f'DELETE FROM `treatment` WHERE id = {id}')
                conn.close()
                return HttpResponse('ok')

def checkin(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return redirect('login/')
    conn = MyHelper()
    list = conn.get_list('SELECT * FROM checkin_view')
    conn.close()
    print(list)
    return render(request, 'checkin/index.html', {'list': list})

def checkin_add(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
    else:
        ticket = None
    if ticket is None:
        return HttpResponse('请先登录！')
    else :
        context = {}
        conn = MyHelper()
        if request.method == 'POST':
            keys = ['bed', 'treatment', 'fee', 'online']
            for key in keys:
                context[key] = request.POST.get(key)
            print(context)
            sql = f'INSERT INTO `checkin` (`bed`, `treatment`, `fee`, `online`) VALUES ("{context["bed"]}", "{context["treatment"]}", "{context["fee"]}", "{context["online"]}")'
            print(sql)
            conn.create(sql)
            conn.close()
            return redirect('/checkin/')
        else:
            return render(request, 'checkin/add.html')

def checkin_delete(request):
    if 'ticket' in request.COOKIES:
        try:
            ticket = request.get_signed_cookie('ticket', salt=__SALT)
        except BadSignature:
            ticket = None
        else:
            if ticket is None:
                return HttpResponse('请先登录！')
            elif int(request.get_signed_cookie('privilege', salt=__SALT)) < 255:
                return HttpResponse('权限不足！')
            elif request.method != 'POST':
                return HttpResponse('请求错误！')
            else:
                conn = MyHelper()
                id = request.POST.get('id')
                conn.modify(f'DELETE FROM `checkin` WHERE id = "{id}"')
                conn.close()
                return HttpResponse('ok')