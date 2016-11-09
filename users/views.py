import sqlite3
from django.shortcuts import render_to_response
from django.http import HttpResponseRedirect
from django.template import RequestContext
from django.core.urlresolvers import reverse
from libvirt import libvirtError

from users.forms import UserForm

def users(request):
    if not request.user.is_authenticated():
        return HttpResponseRedirect(reverse('login'))

    conn = sqlite3.connect('/var/www/webvirtmgr/webvirtmgr/webvirtmgr.sqlite3')
    connect = conn.cursor()

    connect.execute("SELECT id,username,email,is_superuser,is_active,last_login FROM auth_user")
    webusers = connect.fetchall()

    conn.commit()
    connect.close()

    if request.method == 'POST':
        if 'user_del' in request.POST:
		user_id = request.POST.get('user_id', '')
		connect = conn.cursor()
	        connect.execute("DELETE FROM auth_user WHERE id=?", (user_id,))
	        conn.commit()
	        connect.close()
		return HttpResponseRedirect(request.get_full_path())

        if 'user_add' in request.POST:
            form = UserForm(request.POST)
            if form.is_valid():
		name = request.POST.get('name', '')
		print(name)
                return HttpResponseRedirect(request.get_full_path())


    return render_to_response('users.html', locals(), context_instance=RequestContext(request))
